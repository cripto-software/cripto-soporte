// ============================================================
// 📁 RUTA : cripto/flutter/cripto_tecnico.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_tecnico.dart)
// 📌 ARCHIVO: cripto_tecnico.dart
// 📝 RESUMEN: Piezas de CRIPTO Soporte para Windows (programa del
//             técnico): panel «Dar soporte» con la elección Técnico /
//             Acompañante (solo mirar) en la pantalla principal, rol
//             aplicado automáticamente al abrir cada sesión (modo solo
//             ver para el acompañante) y confirmación del permiso del
//             cliente antes de grabar, como exige la política de
//             privacidad (punto 9).
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  25/11/2026  Versión inicial (fase 2 de CRIPTO Soporte Windows).
// ============================================================

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../consts.dart';
import '../models/platform_model.dart';

/// Opción local (compartida por todas las ventanas del programa) con el rol
/// elegido para las próximas conexiones: 'tecnico' o 'acompanante'.
const String kCriptoOpcionRol = 'cripto-rol-tecnico';
const String kCriptoRolTecnico = 'tecnico';
const String kCriptoRolAcompanante = 'acompanante';

const Color kCriptoTecAzul = Color(0xFF2563EB);
const Color kCriptoTecTexto = Color(0xFF0F172A);

String criptoRolActual() {
  final v = bind.mainGetLocalOption(key: kCriptoOpcionRol);
  return v == kCriptoRolAcompanante ? kCriptoRolAcompanante : kCriptoRolTecnico;
}

/// Se llama al recibir la información del equipo remoto (sesión normal).
/// Deja la sesión en «solo ver» si el rol es Acompañante y la quita si es
/// Técnico. Devuelve el valor de «solo ver» que debe mostrar la ventana.
bool criptoAplicarRol(UuidValue sessionId, String peerId) {
  final actual = bind.sessionGetToggleOptionSync(
      sessionId: sessionId, arg: kOptionToggleViewOnly);
  final deseado = criptoRolActual() == kCriptoRolAcompanante;
  if (actual != deseado) {
    bind.sessionToggleOption(sessionId: sessionId, value: kOptionToggleViewOnly);
    debugPrint('[CRIPTO] Rol ${deseado ? 'Acompañante (solo ver)' : 'Técnico'} '
        'aplicado a la sesión');
  }
  return deseado;
}

/// Pregunta al técnico si el cliente aceptó grabar antes de iniciar la
/// grabación. Sin confirmación no se graba.
Future<bool> criptoConfirmarGrabacion(BuildContext context) async {
  final acepto = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('¿El cliente aceptó la grabación?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      content: const SizedBox(
        width: 420,
        child: Text(
          'Antes de grabar, pregunta al cliente si acepta que esta sesión '
          'quede grabada. La grabación se guarda en este computador por '
          '90 días y luego se elimina. Si no acepta, la sesión continúa sin '
          'grabar.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('No aceptó'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: kCriptoTecAzul, foregroundColor: Colors.white),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Sí, aceptó: grabar'),
        ),
      ],
    ),
  );
  debugPrint('[CRIPTO] Grabación ${acepto == true ? 'aceptada' : 'no aceptada'}');
  return acepto == true;
}

/// Panel «Dar soporte» que va arriba del campo del número del cliente.
class CriptoPanelTecnico extends StatefulWidget {
  const CriptoPanelTecnico({Key? key}) : super(key: key);

  @override
  State<CriptoPanelTecnico> createState() => _CriptoPanelTecnicoState();
}

class _CriptoPanelTecnicoState extends State<CriptoPanelTecnico> {
  late String _rol;

  @override
  void initState() {
    super.initState();
    _rol = criptoRolActual();
  }

  Future<void> _elegir(String rol) async {
    setState(() => _rol = rol);
    await bind.mainSetLocalOption(key: kCriptoOpcionRol, value: rol);
    debugPrint('[CRIPTO] Rol elegido para las próximas conexiones: $rol');
  }

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colorTexto = oscuro ? Colors.white : kCriptoTecTexto;
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dar soporte',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: colorTexto)),
          const SizedBox(height: 4),
          Text(
              'Pide al cliente el número que aparece en su CRIPTO Soporte, '
              'escríbelo abajo y pulsa Conectar.',
              style: TextStyle(fontSize: 13, color: colorTexto)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OpcionRol(
                  icono: Icons.build_outlined,
                  titulo: 'Técnico',
                  detalle: 'Ver y controlar el equipo',
                  elegida: _rol == kCriptoRolTecnico,
                  colorTexto: colorTexto,
                  onTap: () => _elegir(kCriptoRolTecnico),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OpcionRol(
                  icono: Icons.visibility_outlined,
                  titulo: 'Acompañante',
                  detalle: 'Solo mirar, sin tocar nada',
                  elegida: _rol == kCriptoRolAcompanante,
                  colorTexto: colorTexto,
                  onTap: () => _elegir(kCriptoRolAcompanante),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OpcionRol extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final bool elegida;
  final Color colorTexto;
  final VoidCallback onTap;

  const _OpcionRol({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.elegida,
    required this.colorTexto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: elegida ? kCriptoTecAzul.withOpacity(0.10) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: elegida ? kCriptoTecAzul : const Color(0xFFCBD5E1),
          width: elegida ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(icono, size: 22, color: elegida ? kCriptoTecAzul : colorTexto),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorTexto)),
                    Text(detalle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: colorTexto)),
                  ],
                ),
              ),
              if (elegida)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.check_circle, size: 20, color: kCriptoTecAzul),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

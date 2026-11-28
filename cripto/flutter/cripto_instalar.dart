// ============================================================
// 📁 RUTA : cripto/flutter/cripto_instalar.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_instalar.dart)
// 📌 ARCHIVO: cripto_instalar.dart
// 📝 RESUMEN: Bienvenida de CRIPTO Soporte para Windows.
//             • Al abrir el programa por primera vez (o cuando cambia la
//               versión de los términos) muestra el mensaje de confianza
//               de PCG S.A.S. sobre la Ley Orgánica de Protección de Datos
//               Personales y pide aceptar los Términos de uso y la Política
//               de privacidad (pc-green.com/cripto-soporte/terminos y /privacidad).
//             • Si el programa NO está instalado, la misma ventana invita a
//               instalarlo («Instalar ahora» abre el instalador de CRIPTO)
//               para que funcione siempre; «Usar sin instalar» deja trabajar.
//             • «No acepto» cierra el programa: sin aceptar no se usa.
//             La aceptación queda guardada en la configuración local con la
//             versión de los términos y la fecha.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  27/11/2026  Versión inicial (mockup aprobado el 26/11/2026).
//   v1.1  27/11/2026  Textos en español e inglés (criptoT, cripto_idioma.dart)
//                     y nombre «CRIPTO Support».
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/platform_model.dart';
import 'cripto_publicidad.dart';
import 'cripto_idioma.dart';

/// Cambiar esta versión obliga a todos a aceptar de nuevo.
const String kCriptoTerminosVersion = '1.0';
const String kCriptoOpcionTerminos = 'cripto-terminos-aceptados';
const String kCriptoOpcionTerminosFecha = 'cripto-terminos-fecha';
const String kCriptoUrlTerminos = 'https://pc-green.com/cripto-soporte/terminos';
const String kCriptoUrlPrivacidad = 'https://pc-green.com/cripto-soporte/privacidad';

const Color kCriptoInsAzul = Color(0xFF2563EB);
const Color kCriptoInsTexto = Color(0xFF0F172A);
const Color kCriptoInsVerdeFondo = Color(0xFFECFDF5);
const Color kCriptoInsVerdeTexto = Color(0xFF065F46);
const Color kCriptoInsError = Color(0xFFB91C1C);

bool criptoTerminosAceptados() =>
    bind.mainGetLocalOption(key: kCriptoOpcionTerminos) == kCriptoTerminosVersion;

/// Widget invisible que se coloca en la pantalla principal y abre la
/// bienvenida cuando hace falta (términos sin aceptar o programa sin instalar).
class CriptoAvisoInstalacion extends StatefulWidget {
  const CriptoAvisoInstalacion({Key? key}) : super(key: key);

  @override
  State<CriptoAvisoInstalacion> createState() => _CriptoAvisoInstalacionState();
}

class _CriptoAvisoInstalacionState extends State<CriptoAvisoInstalacion> {
  @override
  void initState() {
    super.initState();
    if (!Platform.isWindows) return;
    final instalado = bind.mainIsInstalled();
    final aceptado = criptoTerminosAceptados();
    if (instalado && aceptado) return;
    // Hoy ya no se muestra además el aviso de publicidad: una sola ventana.
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    bind.mainSetLocalOption(key: kCriptoOpcionAvisoDia, value: hoy);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      debugPrint('[CRIPTO] Bienvenida: instalado=$instalado, términos=$aceptado');
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _VentanaBienvenida(instalado: instalado, aceptado: aceptado),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _VentanaBienvenida extends StatefulWidget {
  final bool instalado;
  final bool aceptado;
  const _VentanaBienvenida({required this.instalado, required this.aceptado});

  @override
  State<_VentanaBienvenida> createState() => _VentanaBienvenidaState();
}

class _VentanaBienvenidaState extends State<_VentanaBienvenida> {
  late bool _marcado = widget.aceptado;
  bool _falta = false;

  Future<bool> _guardarAceptacion() async {
    if (!_marcado) {
      setState(() => _falta = true);
      return false;
    }
    if (!widget.aceptado) {
      await bind.mainSetLocalOption(key: kCriptoOpcionTerminos, value: kCriptoTerminosVersion);
      await bind.mainSetLocalOption(
          key: kCriptoOpcionTerminosFecha, value: DateTime.now().toIso8601String());
      debugPrint('[CRIPTO] Bienvenida: términos v$kCriptoTerminosVersion aceptados');
    }
    return true;
  }

  Future<void> _instalar() async {
    if (!await _guardarAceptacion()) return;
    if (mounted) Navigator.of(context).pop();
    debugPrint('[CRIPTO] Bienvenida: abre el instalador');
    bind.mainGotoInstall();
  }

  Future<void> _continuar() async {
    if (!await _guardarAceptacion()) return;
    if (mounted) Navigator.of(context).pop();
  }

  void _noAcepto() {
    debugPrint('[CRIPTO] Bienvenida: el usuario no aceptó los términos; se cierra');
    exit(0);
  }

  Widget _enlace(String texto, String url) => InkWell(
        onTap: () => launchUrl(Uri.parse(url)),
        child: Text(texto,
            style: const TextStyle(
                fontSize: 13, color: kCriptoInsAzul, decoration: TextDecoration.underline)),
      );

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final texto = oscuro ? Colors.white : kCriptoInsTexto;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                child: const Icon(Icons.headset_mic_outlined, color: kCriptoInsAzul, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(criptoT('Bienvenido a CRIPTO Support'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: texto)),
                  Text(criptoT('Soporte remoto de PCG SAS, Quito – Ecuador'),
                      style: TextStyle(fontSize: 13, color: texto)),
                ]),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: kCriptoInsVerdeFondo, borderRadius: BorderRadius.circular(8)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.verified_user_outlined, color: kCriptoInsVerdeTexto, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    criptoT('Su seguridad es nuestra prioridad. Cumplimos la Ley Orgánica de Protección de Datos Personales: nadie puede ver ni controlar su equipo sin que usted lo acepte, y usted puede terminar la sesión cuando quiera.'),
                    style: TextStyle(fontSize: 13, height: 1.5, color: kCriptoInsVerdeTexto),
                  ),
                ),
              ]),
            ),
            if (!widget.instalado) ...[
              const SizedBox(height: 12),
              Text(
                criptoT('Instale CRIPTO Support para tener acceso directo en el escritorio y recibir soporte incluso después de reiniciar el equipo.'),
                style: TextStyle(fontSize: 13, color: texto),
              ),
            ],
            if (!widget.aceptado) ...[
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(
                  value: _marcado,
                  activeColor: kCriptoInsAzul,
                  onChanged: (v) => setState(() {
                    _marcado = v ?? false;
                    if (_marcado) _falta = false;
                  }),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Text(criptoT('He leído y acepto los '), style: TextStyle(fontSize: 13, color: texto)),
                      _enlace(criptoT('Términos de uso'), kCriptoUrlTerminos),
                      Text(criptoT(' y la '), style: TextStyle(fontSize: 13, color: texto)),
                      _enlace(criptoT('Política de privacidad'), kCriptoUrlPrivacidad),
                      Text('.', style: TextStyle(fontSize: 13, color: texto)),
                    ]),
                  ),
                ),
              ]),
              if (_falta)
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(criptoT('Marque la casilla para continuar.'),
                      style: TextStyle(fontSize: 13, color: kCriptoInsError)),
                ),
            ],
            const SizedBox(height: 16),
            Row(children: [
              if (!widget.instalado) ...[
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _instalar,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kCriptoInsAzul,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    icon: const Icon(Icons.download_outlined, color: Colors.white, size: 18),
                    label: Text(criptoT('Instalar ahora'), style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _continuar,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(criptoT('Usar sin instalar')),
                  ),
                ),
              ] else
                Expanded(
                  child: ElevatedButton(
                    onPressed: _continuar,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kCriptoInsAzul,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(criptoT('Aceptar y continuar'), style: TextStyle(color: Colors.white)),
                  ),
                ),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(criptoT('¿Dudas? WhatsApp 098 566 6807'), style: TextStyle(fontSize: 13, color: texto)),
              if (!widget.aceptado)
                TextButton(onPressed: _noAcepto, child: Text(criptoT('No acepto'))),
            ]),
          ],
        ),
      ),
    );
  }
}

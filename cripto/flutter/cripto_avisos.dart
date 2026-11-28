// ============================================================
// 📁 RUTA : cripto/flutter/cripto_avisos.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_avisos.dart)
// 📌 ARCHIVO: cripto_avisos.dart
// 📝 RESUMEN: Avisos de CRIPTO Soporte que exige Google Play
//             ("divulgación destacada") y que protegen al cliente:
//             1) CriptoAvisoSeguridad: reemplaza el aviso de estafas
//                del motor original antes de compartir la pantalla.
//             2) criptoAvisoAccesibilidad: explica el uso del
//                permiso de Accesibilidad antes de abrir Ajustes.
//             Ninguno se puede saltar: el permiso solo se pide si
//             el cliente pulsa el botón de aceptar.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  24/11/2026  Versión inicial.
//   v1.1  24/11/2026  (v1.2 de la app) El teléfono ya no se corta en dos
//                     líneas; botones del aviso de Accesibilidad a lo ancho
//                     y alineados; criptoPrepararCarpetas reemplaza las dos
//                     preguntas de carpetas del motor original (registros y
//                     archivos) por la carpeta propia de la app, sin
//                     preguntar.
//   v1.2  27/11/2026  Textos en español e inglés (criptoT, cripto_idioma.dart)
//                     y nombre «CRIPTO Support».
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../common.dart';
import '../consts.dart';
import '../models/model.dart';
import '../models/platform_model.dart';
import '../models/server_model.dart';
import 'cripto_lopdp.dart';
import '../utils/android_documents.dart';
import 'cripto_idioma.dart';

const TextStyle _titulo =
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kCriptoTexto);
const TextStyle _cuerpo = TextStyle(fontSize: 16, color: kCriptoTexto, height: 1.4);
const TextStyle _cuerpoNegrita =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kCriptoTexto);
const TextStyle _pequeno = TextStyle(fontSize: 14, color: kCriptoTexto, height: 1.4);

const Color _rojoFondo = Color(0xFFFEF2F2);
const Color _rojoBorde = Color(0xFFDC2626);
const Color _rojoTexto = Color(0xFF991B1B);

Widget _vineta(String texto, {TextStyle estilo = _cuerpo}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•  ', style: estilo),
        Expanded(child: Text(texto, style: estilo)),
      ],
    ),
  );
}

Widget _botonPrincipal(String texto, VoidCallback? alPulsar) {
  return SizedBox(
    height: 48,
    child: ElevatedButton(
      onPressed: alPulsar,
      style: ElevatedButton.styleFrom(
        backgroundColor: kCriptoAzul,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(texto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );
}

Widget _botonSecundario(String texto, VoidCallback alPulsar) {
  return SizedBox(
    height: 48,
    child: OutlinedButton(
      onPressed: alPulsar,
      style: OutlinedButton.styleFrom(
        foregroundColor: kCriptoAzul,
        side: const BorderSide(color: kCriptoAzul),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(texto, style: _cuerpoNegrita),
    ),
  );
}

// ============================================================
// 1) Aviso de seguridad antes de compartir la pantalla
// ============================================================
class CriptoAvisoSeguridad extends StatefulWidget {
  final ServerModel serverModel;
  const CriptoAvisoSeguridad({Key? key, required this.serverModel})
      : super(key: key);

  @override
  State<CriptoAvisoSeguridad> createState() => _CriptoAvisoSeguridadState();
}

class _CriptoAvisoSeguridadState extends State<CriptoAvisoSeguridad> {
  static const int _segundos = 5;
  int _cuenta = _segundos;
  bool _noMostrar = false;
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    debugPrint('[CRIPTO] Aviso de seguridad mostrado');
    _reloj = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cuenta--;
        if (_cuenta <= 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  void _iniciar() {
    debugPrint('[CRIPTO] Aviso de seguridad aceptado; '
        'no volver a mostrar: $_noMostrar');
    Navigator.of(context).pop();
    if (_noMostrar) {
      bind.mainSetLocalOption(key: "show-scam-warning", value: "N");
    }
    widget.serverModel.toggleService();
  }

  @override
  Widget build(BuildContext context) {
    final bloqueado = _cuenta > 0;
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      title: Row(
        children: [
          Icon(Icons.shield, size: 32, color: kCriptoAzul),
          SizedBox(width: 12),
          Expanded(
              child: Text(criptoT('Antes de compartir tu pantalla'), style: _titulo)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              criptoT('Al iniciar, el técnico de CRIPTO Software podrá ver tu pantalla para ayudarte. Tú decides cada conexión: siempre te pediremos permiso y puedes cortarla cuando quieras.'),
              style: _cuerpo,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _rojoFondo,
                border: Border.all(color: _rojoBorde),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 24, color: _rojoBorde),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(criptoT('Cuidado con las estafas'),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _rojoTexto)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _vineta(
                      criptoT('Comparte tu ID y contraseña solo con un técnico de CRIPTO Software al que tú llamaste.'),
                      estilo: const TextStyle(
                          fontSize: 16, color: _rojoTexto, height: 1.4)),
                  _vineta(
                      criptoT('Nunca te pediremos claves del banco, códigos que te lleguen por mensaje ni dinero.'),
                      estilo: const TextStyle(
                          fontSize: 16, color: _rojoTexto, height: 1.4)),
                  _vineta(
                      criptoT('Si alguien te llama diciendo ser del banco, de la policía u otra empresa y te pide usar esta app, cuelga.'),
                      estilo: const TextStyle(
                          fontSize: 16, color: _rojoTexto, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              criptoT('Soporte oficial: {correo} · {telefono}', {'correo': kCriptoCorreo, 'telefono': kCriptoTelefono.replaceAll(' ', '\u00A0')}),
              style: _pequeno,
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () => setState(() => _noMostrar = !_noMostrar),
              child: Row(
                children: [
                  Checkbox(
                    value: _noMostrar,
                    activeColor: kCriptoAzul,
                    onChanged: (v) => setState(() => _noMostrar = v ?? false),
                  ),
                  Expanded(
                      child: Text(criptoT('No volver a mostrar'), style: _pequeno)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _botonSecundario(
                      criptoT('Cancelar'), () => Navigator.of(context).pop()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _botonPrincipal(
                    bloqueado ? criptoT('Entiendo ({n})', {'n': _cuenta}) : criptoT('Entiendo, iniciar'),
                    bloqueado ? null : _iniciar,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 2) Divulgación destacada del permiso de Accesibilidad
//    (reemplaza al diálogo original antes de abrir Ajustes)
// ============================================================
void criptoAvisoAccesibilidad(FFI ffi) {
  debugPrint('[CRIPTO] Aviso de Accesibilidad mostrado');
  ffi.dialogManager.show((setState, close, context) {
    void aceptar() {
      debugPrint('[CRIPTO] Aviso de Accesibilidad aceptado; abriendo Ajustes');
      AndroidPermissionManager.startAction(kActionAccessibilitySettings);
      close();
    }

    void cancelar() {
      debugPrint('[CRIPTO] Aviso de Accesibilidad cancelado');
      close();
    }

    return CustomAlertDialog(
      title: Row(
        children: [
          Icon(Icons.touch_app, size: 32, color: kCriptoAzul),
          SizedBox(width: 12),
          Expanded(child: Text(criptoT('Permiso de control remoto'), style: _titulo)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criptoT('CRIPTO Support usa el servicio de Accesibilidad de Android solo para que el técnico pueda tocar y escribir en tu pantalla durante una sesión de soporte que tú aceptaste.'),
            style: _cuerpo,
          ),
          const SizedBox(height: 12),
          _vineta(criptoT('Funciona solo mientras la sesión está activa, y tú puedes cortarla en cualquier momento.')),
          _vineta(criptoT('No lee tus mensajes ni contraseñas, y no recopila datos en segundo plano.')),
          _vineta(criptoT('No se usa para guardar ni compartir con terceros lo que aparece en tu pantalla.')),
          const SizedBox(height: 8),
          Text(
            criptoT('Al pulsar «Aceptar y abrir Ajustes», busca «CRIPTO Support Control» y actívalo.'),
            style: _cuerpoNegrita,
          ),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: _botonPrincipal(criptoT('Aceptar y abrir Ajustes'), aceptar)),
          const SizedBox(height: 8),
          SizedBox(
              width: double.infinity,
              child: _botonSecundario(criptoT('Cancelar'), cancelar)),
        ],
      ),
      onSubmit: aceptar,
      onCancel: cancelar,
    );
  });
}

// ============================================================
// 3) Carpetas sin preguntas (v1.2 de la app)
//    El motor original preguntaba dónde guardar sus registros y qué carpeta
//    podía ver el técnico. CRIPTO usa siempre la carpeta propia de la
//    app: el técnico nunca ve fotos, documentos ni descargas.
// ============================================================
const String _claveCarpetas = 'android-file-transfer-folder-setup';

Future<void> criptoPrepararCarpetas(FFI ffi) async {
  if (bind.getLocalFlutterOption(k: _claveCarpetas) == 'Y') return;
  try {
    await AndroidDocuments.workspace(share: true);
    await bind.setLocalFlutterOption(k: _claveCarpetas, v: 'Y');
    debugPrint('[CRIPTO] Carpeta de archivos: solo la carpeta de la app');
  } catch (e) {
    debugPrint('[CRIPTO] No se pudo preparar la carpeta de la app: $e');
  }
}

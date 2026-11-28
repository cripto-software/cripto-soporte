// ============================================================
// 📁 RUTA : cripto/flutter/cripto_pro.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_pro.dart)
// 📌 ARCHIVO: cripto_pro.dart
// 📝 RESUMEN: Funciones Pro de CRIPTO Soporte para Windows (programa
//             del técnico). La llamada de voz, la transferencia de
//             archivos y la grabación de la sesión necesitan una
//             licencia de técnico activa. Sin licencia se muestra la
//             ventana «Función Pro» (conocer CRIPTO Pro, activar la
//             licencia o seguir sin Pro) y una insignia PRO junto a
//             cada opción. Nunca se bloquea ni se corta la sesión: solo
//             la función Pro elegida espera la licencia.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  27/11/2026  Versión inicial (fase 1 de CRIPTO Soporte Windows v2.6).
//   v1.1  27/11/2026  Textos en español e inglés (criptoT, cripto_idioma.dart)
//                     y nombre «CRIPTO Support».
// ============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common.dart';
import 'cripto_licencia.dart';
import 'cripto_idioma.dart';

const String kCriptoUrlPro = 'https://pc-green.com/cripto-soporte';
const String kCriptoWhatsAppPro = '593985666807';
const String kCriptoWhatsAppProVisible = '098 566 6807';

const Color kCriptoProAzul = Color(0xFF2563EB);
const Color kCriptoProAzulSuave = Color(0xFFEFF6FF);
const Color kCriptoProTexto = Color(0xFF0F172A);
const Color kCriptoProBorde = Color(0xFFE2E8F0);
const Color kCriptoProAmbar = Color(0xFFB45309);
const Color kCriptoProAmbarSuave = Color(0xFFFEF3C7);

/// Funciones que exigen licencia de técnico.
enum CriptoFuncionPro { llamada, archivos, grabacion }

extension CriptoFuncionProTexto on CriptoFuncionPro {
  /// Título de la ventana: «La … es una función Pro».
  String get titulo {
    switch (this) {
      case CriptoFuncionPro.llamada:
        return criptoT('La llamada de voz es una función Pro');
      case CriptoFuncionPro.archivos:
        return criptoT('La transferencia de archivos es una función Pro');
      case CriptoFuncionPro.grabacion:
        return criptoT('La grabación de la sesión es una función Pro');
    }
  }

  /// Campo que envía el servidor de licencias al activar (si lo envía).
  String get campoLicencia {
    switch (this) {
      case CriptoFuncionPro.llamada:
        return 'permiteAudio';
      case CriptoFuncionPro.archivos:
        return 'permiteArchivos';
      case CriptoFuncionPro.grabacion:
        return 'permiteGrabacion';
    }
  }

  String get nombreLog {
    switch (this) {
      case CriptoFuncionPro.llamada:
        return 'llamada';
      case CriptoFuncionPro.archivos:
        return 'archivos';
      case CriptoFuncionPro.grabacion:
        return 'grabación';
    }
  }
}

/// true si la licencia de técnico activa incluye la función.
/// Sin licencia = false. Con licencia, solo se niega si el servidor envió
/// expresamente el permiso en false.
bool criptoPermiteFuncion(CriptoFuncionPro funcion) {
  final info = criptoLicenciaInfo();
  if (info == null) return false;
  return info[funcion.campoLicencia] != false;
}

/// Revisa la función Pro antes de usarla. Si no está permitida muestra la
/// ventana «Función Pro». Devuelve true solo si se puede continuar.
Future<bool> criptoPermitePro(
    BuildContext context, CriptoFuncionPro funcion) async {
  if (criptoPermiteFuncion(funcion)) return true;
  debugPrint('[CRIPTO] Función Pro sin licencia: ${funcion.nombreLog}');
  final ctx = context.mounted ? context : globalKey.currentContext;
  if (ctx == null) return false;
  final activar = await showDialog<bool>(
    context: ctx,
    builder: (_) => _VentanaFuncionPro(funcion: funcion),
  );
  if (activar == true && ctx.mounted) {
    await criptoMostrarActivarLicencia(ctx);
    final permitido = criptoPermiteFuncion(funcion);
    debugPrint('[CRIPTO] Función Pro ${funcion.nombreLog} tras activar: '
        '${permitido ? 'permitida' : 'sin permiso'}');
    return permitido;
  }
  debugPrint('[CRIPTO] El técnico siguió sin Pro (${funcion.nombreLog})');
  return false;
}

/// Insignia «PRO» junto a la opción cuando la licencia no la incluye.
Widget criptoInsigniaPro(CriptoFuncionPro funcion) {
  if (criptoPermiteFuncion(funcion)) return const SizedBox.shrink();
  return Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: kCriptoProAmbarSuave,
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text('PRO',
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: kCriptoProAmbar,
            letterSpacing: 0.5)),
  );
}

/// Texto de una opción del menú con su insignia PRO.
Widget criptoTextoConInsignia(String texto, CriptoFuncionPro funcion) {
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Text(texto),
    criptoInsigniaPro(funcion),
  ]);
}

Future<void> _abrir(Uri url) async {
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
    debugPrint('[CRIPTO] Función Pro: se abrió ${url.host}');
  } catch (e) {
    debugPrint('[CRIPTO] Función Pro: no se pudo abrir el enlace: ${e.runtimeType}');
  }
}

class _VentanaFuncionPro extends StatelessWidget {
  final CriptoFuncionPro funcion;
  const _VentanaFuncionPro({required this.funcion});

  static const _beneficios = [
    'Llamada de voz con el cliente durante el soporte',
    'Envío y recepción de archivos con el equipo del cliente',
    'Grabación de la sesión (con el permiso del cliente)',
    'Registro de cada sesión con la hora del servidor',
    'Soporte prioritario por WhatsApp',
  ];

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colorTexto = oscuro ? Colors.white : kCriptoProTexto;
    final estiloBoton = ButtonStyle(
      minimumSize: MaterialStateProperty.all(const Size(0, 40)),
      padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16)),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    );
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: kCriptoProAmbarSuave,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('PRO',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kCriptoProAmbar,
                  letterSpacing: 0.5)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(funcion.titulo,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorTexto)),
        ),
      ]),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              criptoT('Puede seguir dando soporte sin interrupciones. Para usar esta función active su licencia de técnico CRIPTO Pro.'),
              style: TextStyle(fontSize: 14, height: 1.5, color: colorTexto),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: oscuro ? Colors.white10 : kCriptoProAzulSuave,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: oscuro ? Colors.white24 : kCriptoProBorde),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(criptoT('CRIPTO Pro incluye:'),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorTexto)),
                  const SizedBox(height: 8),
                  for (final b in _beneficios)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 16, color: kCriptoProAzul),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(criptoT(b),
                                style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: colorTexto)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _abrir(Uri.parse(
                  'https://wa.me/$kCriptoWhatsAppPro?text=${Uri.encodeComponent(criptoT('Hola, quiero la licencia CRIPTO Pro para técnicos.'))}')),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.chat, size: 16, color: Color(0xFF15803D)),
                  const SizedBox(width: 8),
                  Text(criptoT('¿Dudas? WhatsApp {telefono}', {'telefono': kCriptoWhatsAppProVisible}),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF15803D))),
                ]),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: estiloBoton,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(criptoT('Seguir sin Pro')),
        ),
        OutlinedButton(
          style: estiloBoton,
          onPressed: () => _abrir(Uri.parse(kCriptoUrlPro)),
          child: Text(criptoT('Conocer CRIPTO Pro')),
        ),
        ElevatedButton(
          style: estiloBoton.copyWith(
            backgroundColor: MaterialStateProperty.all(kCriptoProAzul),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(criptoT('Activar licencia de técnico')),
        ),
      ],
    );
  }
}

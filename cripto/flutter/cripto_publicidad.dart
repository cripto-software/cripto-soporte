// ============================================================
// 📁 RUTA : cripto/flutter/cripto_publicidad.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_publicidad.dart)
// 📌 ARCHIVO: cripto_publicidad.dart
// 📝 RESUMEN: Publicidad de CRIPTO Soporte para Windows (versión gratis):
//             tarjeta que rota cada 6 segundos en la barra izquierda
//             (CRIPTO ERP y tienda PCGreen), logo de CRIPTO Software al
//             pie con enlace a pc-green.com y aviso de bienvenida que sale
//             una sola vez al día al abrir el programa (nunca durante una
//             sesión de soporte).
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  25/11/2026  Versión inicial (fase publicidad).
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/platform_model.dart';
import '../models/state_model.dart';

/// Página a la que llevan todos los enlaces de publicidad.
const String kCriptoUrlPagina = 'https://pc-green.com';

/// Opción local con la fecha (aaaa-mm-dd) del último aviso mostrado.
const String kCriptoOpcionAvisoDia = 'cripto-aviso-dia';

const Color kCriptoPubAzul = Color(0xFF2563EB);
const Color kCriptoPubMarino = Color(0xFF0B1029);
const Color kCriptoPubVerde = Color(0xFF052E16);
const Color kCriptoPubVerdeClaro = Color(0xFF16A34A);
const Color kCriptoPubTexto = Color(0xFF0F172A);

Future<void> criptoAbrirPagina() async {
  try {
    await launchUrl(Uri.parse(kCriptoUrlPagina),
        mode: LaunchMode.externalApplication);
    debugPrint('[CRIPTO] Publicidad: se abrió $kCriptoUrlPagina');
  } catch (e) {
    debugPrint('[CRIPTO] Publicidad: no se pudo abrir la página: $e');
  }
}

class _Anuncio {
  final String etiqueta;
  final String titulo;
  final String detalle;
  final String boton;
  final Color fondo;
  final Color colorEtiqueta;
  final Color colorDetalle;
  const _Anuncio(this.etiqueta, this.titulo, this.detalle, this.boton,
      this.fondo, this.colorEtiqueta, this.colorDetalle);
}

const List<_Anuncio> _anuncios = [
  _Anuncio(
    'CRIPTO ERP',
    'Factura electrónica, inventario y contabilidad en un solo sistema',
    'Hecho en Ecuador, listo para el SRI.',
    'Conocer CRIPTO ERP',
    kCriptoPubMarino,
    kCriptoPubAzul,
    Color(0xFFE2E8F0),
  ),
  _Anuncio(
    'PCGreen',
    'Impresoras, lectores y equipos para tu negocio',
    'Instalación y soporte incluidos.',
    'Ver la tienda',
    kCriptoPubVerde,
    kCriptoPubVerdeClaro,
    Color(0xFFDCFCE7),
  ),
];

/// Bloque de publicidad para la barra izquierda de la pantalla principal.
class CriptoPanelPublicidad extends StatefulWidget {
  const CriptoPanelPublicidad({Key? key}) : super(key: key);

  @override
  State<CriptoPanelPublicidad> createState() => _CriptoPanelPublicidadState();
}

class _CriptoPanelPublicidadState extends State<CriptoPanelPublicidad> {
  int _actual = 0;
  Timer? _rotacion;

  @override
  void initState() {
    super.initState();
    _rotacion = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) setState(() => _actual = (_actual + 1) % _anuncios.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _avisoDelDia());
  }

  @override
  void dispose() {
    _rotacion?.cancel();
    super.dispose();
  }

  Future<void> _avisoDelDia() async {
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    if (bind.mainGetLocalOption(key: kCriptoOpcionAvisoDia) == hoy) return;
    // Nunca durante una sesión de soporte (alguien conectado a este equipo).
    if (criptoHaySesionActiva()) return;
    await bind.mainSetLocalOption(key: kCriptoOpcionAvisoDia, value: hoy);
    if (!mounted) return;
    debugPrint('[CRIPTO] Publicidad: aviso del día mostrado');
    await showDialog<void>(
      context: context,
      builder: (ctx) => const _AvisoBienvenida(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = _anuncios[_actual];
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        children: [
          Material(
            color: a.fondo,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: criptoAbrirPagina,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: a.colorEtiqueta,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(a.etiqueta,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 10),
                    Text(a.titulo,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.25)),
                    const SizedBox(height: 6),
                    Text(a.detalle,
                        style: TextStyle(
                            color: a.colorDetalle, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 12),
                    Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(a.boton,
                          style: TextStyle(
                              color: a.fondo,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _anuncios.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _actual = i),
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _actual
                        ? kCriptoPubAzul
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          InkWell(
            onTap: criptoAbrirPagina,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Image.asset('assets/cripto_software.png',
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  const SizedBox(height: 4),
                  Text('pc-green.com',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: oscuro ? Colors.white : kCriptoPubAzul)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hay alguien viendo este equipo (sesión de soporte activa).
bool criptoHaySesionActiva() => stateGlobal.videoConnCount.value > 0;

class _AvisoBienvenida extends StatelessWidget {
  const _AvisoBienvenida();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 680,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 250,
                color: kCriptoPubMarino,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/cripto_software.png',
                        width: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                    const SizedBox(height: 16),
                    const Text('El sistema de los negocios que crecen en Ecuador',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFE2E8F0), fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Gracias por usar CRIPTO Soporte',
                          style: TextStyle(
                              color: kCriptoPubAzul,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      const Text('¿Tu negocio todavía factura a mano?',
                          style: TextStyle(
                              color: kCriptoPubTexto,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.25)),
                      const SizedBox(height: 14),
                      for (final b in const [
                        'Factura electrónica autorizada por el SRI',
                        'Inventario, compras y contabilidad al día',
                        'Soporte técnico incluido con CRIPTO Soporte',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [
                            const Icon(Icons.check_circle,
                                size: 18, color: kCriptoPubVerdeClaro),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(b,
                                    style: const TextStyle(
                                        color: kCriptoPubTexto, fontSize: 14))),
                          ]),
                        ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kCriptoPubAzul,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: () {
                                Navigator.of(context).pop();
                                criptoAbrirPagina();
                              },
                              child: const Text('Quiero conocerlo',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Ahora no',
                                style: TextStyle(
                                    color: kCriptoPubTexto, fontSize: 14)),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 📁 RUTA : cripto/flutter/cripto_publicidad.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_publicidad.dart)
// 📌 ARCHIVO: cripto_publicidad.dart
// 📝 RESUMEN: Publicidad de CRIPTO Soporte para Windows (versión gratis):
//             tarjeta clara que rota en la barra izquierda con lo que
//             ofrece PCG SAS por nichos (CRIPTO ERP para supermercados,
//             clínicas, repuestos y restaurantes; equipos de punto de
//             venta; licencias de antivirus, Office y Windows), botón de
//             WhatsApp de soporte y ventas, logo de CRIPTO Software al pie
//             con enlace a pc-green.com y aviso de bienvenida que sale una
//             sola vez al día al abrir el programa (nunca durante una
//             sesión de soporte).
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  25/11/2026  Versión inicial (fase publicidad).
//   v2.0  26/11/2026  Publicidad por nichos: 6 anuncios (Supermercados y
//                     tiendas, Clínicas y consultorios, Repuestos y
//                     ferreterías, Restaurantes, Equipos de punto de venta,
//                     Licencias originales) en una tarjeta clara con letra
//                     normal (sin negrillas fuertes), ícono por nicho y tres
//                     puntos de cada uno. Rota cada 7 segundos y se detiene
//                     mientras el mouse está encima. Nuevo botón de WhatsApp
//                     (098 566 6807) que abre el chat de soporte y ventas.
//                     Los dos anuncios oscuros de la v1.0 (CRIPTO ERP y
//                     PCGreen) se reemplazan por estos seis. El aviso de
//                     bienvenida sigue igual, con letra más liviana.
//   v2.1  27/11/2026  Textos en español e inglés (criptoT, cripto_idioma.dart)
//                     y nombre «CRIPTO Support».
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/platform_model.dart';
import '../models/state_model.dart';
import 'cripto_idioma.dart';

/// Página a la que llevan todos los enlaces de publicidad.
const String kCriptoUrlPagina = 'https://pc-green.com';

/// Teléfono de soporte y ventas (WhatsApp), formato internacional sin «+».
const String kCriptoWhatsApp = '593985666807';

/// Teléfono tal como se muestra en pantalla.
const String kCriptoWhatsAppVisible = '098 566 6807';

/// Mensaje con el que se abre el chat de WhatsApp.
const String kCriptoWhatsAppMensaje =
    'Hola, necesito información o ayuda con CRIPTO.';

/// Opción local con la fecha (aaaa-mm-dd) del último aviso mostrado.
const String kCriptoOpcionAvisoDia = 'cripto-aviso-dia';

const Color kCriptoPubAzul = Color(0xFF2563EB);
const Color kCriptoPubAzulOscuro = Color(0xFF1D4ED8);
const Color kCriptoPubAzulSuave = Color(0xFFEFF6FF);
const Color kCriptoPubMarino = Color(0xFF0B1029);
const Color kCriptoPubVerdeClaro = Color(0xFF16A34A);
const Color kCriptoPubWhatsApp = Color(0xFF25D366);
const Color kCriptoPubTexto = Color(0xFF0F172A);
const Color kCriptoPubBorde = Color(0xFFE2E8F0);

Future<void> criptoAbrirPagina() async {
  try {
    await launchUrl(Uri.parse(kCriptoUrlPagina),
        mode: LaunchMode.externalApplication);
    debugPrint('[CRIPTO] Publicidad: se abrió $kCriptoUrlPagina');
  } catch (e) {
    debugPrint('[CRIPTO] Publicidad: no se pudo abrir la página: $e');
  }
}

/// v2.0 — Abre el chat de WhatsApp de soporte y ventas.
Future<void> criptoAbrirWhatsApp() async {
  final url = Uri.parse('https://wa.me/$kCriptoWhatsApp'
      '?text=${Uri.encodeComponent(criptoT(kCriptoWhatsAppMensaje))}');
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
    debugPrint('[CRIPTO] Publicidad: se abrió el chat de WhatsApp');
  } catch (e) {
    debugPrint('[CRIPTO] Publicidad: no se pudo abrir WhatsApp: $e');
  }
}

class _Anuncio {
  final String etiqueta;
  final String titulo;
  final IconData icono;
  final List<String> puntos;
  const _Anuncio(this.etiqueta, this.titulo, this.icono, this.puntos);
}

const List<_Anuncio> _anuncios = [
  _Anuncio(
    'CRIPTO ERP · Supermercados y tiendas',
    'Vende rápido y factura al instante',
    Icons.shopping_cart_outlined,
    [
      'Punto de venta con lector y balanza',
      'Inventario y kardex en tiempo real',
      'Facturación electrónica lista para el SRI',
    ],
  ),
  _Anuncio(
    'CRIPTO ERP · Clínicas y consultorios',
    'Tu consulta ordenada de principio a fin',
    Icons.local_hospital_outlined,
    [
      'Agenda de citas y pacientes',
      'Historia clínica y receta',
      'Facturación de consultas y servicios',
    ],
  ),
  _Anuncio(
    'CRIPTO ERP · Repuestos y ferreterías',
    'Encuentra cada pieza en segundos',
    Icons.build_outlined,
    [
      'Catálogo con fotos y códigos',
      'Existencias por bodega',
      'Compras, retenciones y ATS',
    ],
  ),
  _Anuncio(
    'CRIPTO ERP · Restaurantes',
    'Mesas, comandas y caja bajo control',
    Icons.restaurant_outlined,
    [
      'Pedidos por mesa',
      'Recibo térmico y factura',
      'Cierre de caja diario',
    ],
  ),
  _Anuncio(
    'PCGreen · Equipos de punto de venta',
    'Todo el equipo para tu caja',
    Icons.print_outlined,
    [
      'Impresoras térmicas y lectores',
      'Cajones de dinero y balanzas',
      'Instalación y configuración incluidas',
    ],
  ),
  _Anuncio(
    'PCGreen · Licencias originales',
    'Software legal y protegido',
    Icons.verified_user_outlined,
    [
      'Antivirus para PC y celular',
      'Microsoft Office y Windows',
      'Instalación por soporte remoto',
    ],
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
  bool _pausado = false;
  Timer? _rotacion;

  @override
  void initState() {
    super.initState();
    _rotacion = Timer.periodic(const Duration(seconds: 7), (_) {
      if (mounted && !_pausado) {
        setState(() => _actual = (_actual + 1) % _anuncios.length);
      }
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
    final texto = oscuro ? Colors.white : kCriptoPubTexto;
    final fondoTarjeta = oscuro ? const Color(0xFF1E293B) : Colors.white;
    final borde = oscuro ? const Color(0xFF334155) : kCriptoPubBorde;
    final azulTexto = oscuro ? const Color(0xFF93C5FD) : kCriptoPubAzulOscuro;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        children: [
          // Tarjeta del anuncio (toda la tarjeta lleva a pc-green.com).
          MouseRegion(
            onEnter: (_) => _pausado = true,
            onExit: (_) => _pausado = false,
            child: Material(
              color: fondoTarjeta,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borde),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: criptoAbrirPagina,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                    key: ValueKey<int>(_actual),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: oscuro
                                    ? const Color(0xFF1E3A8A)
                                    : kCriptoPubAzulSuave,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(a.icono,
                                  size: 18,
                                  color: oscuro
                                      ? const Color(0xFFBFDBFE)
                                      : kCriptoPubAzul),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(criptoT(a.etiqueta),
                                  style: TextStyle(
                                      color: azulTexto,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(criptoT(a.titulo),
                            style: TextStyle(
                                color: texto,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.3)),
                        const SizedBox(height: 8),
                        for (final p in a.puntos)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: Icon(Icons.check,
                                      size: 14,
                                      color: oscuro
                                          ? const Color(0xFF93C5FD)
                                          : kCriptoPubAzul),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(criptoT(p),
                                      style: TextStyle(
                                          color: texto,
                                          fontSize: 12,
                                          height: 1.35)),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(criptoT('Ver más en pc-green.com →'),
                            style: TextStyle(
                                color: azulTexto,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Puntos para elegir el anuncio (el actual se ve alargado).
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _anuncios.length,
              (i) => Tooltip(
                message: criptoT(_anuncios[i].etiqueta),
                child: GestureDetector(
                  onTap: () => setState(() => _actual = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _actual ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == _actual
                          ? kCriptoPubAzul
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // v2.0 — WhatsApp de soporte y ventas.
          Material(
            color: fondoTarjeta,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                  color: oscuro ? const Color(0xFF14532D) : const Color(0xFFBBF7D0)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: criptoAbrirWhatsApp,
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                          color: kCriptoPubWhatsApp, shape: BoxShape.circle),
                      child: const Icon(Icons.chat_rounded,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(criptoT('Soporte y ventas por WhatsApp'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: texto, fontSize: 11)),
                          Text(kCriptoWhatsAppVisible,
                              style: TextStyle(
                                  color: texto,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                          fontWeight: FontWeight.w500,
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
                    Text(criptoT('El sistema de los negocios que crecen en Ecuador'),
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
                      Text(criptoT('Gracias por usar CRIPTO Support'),
                          style: TextStyle(
                              color: kCriptoPubAzul,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Text(criptoT('¿Tu negocio todavía factura a mano?'),
                          style: TextStyle(
                              color: kCriptoPubTexto,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.25)),
                      const SizedBox(height: 14),
                      for (final b in [
                        criptoT('Factura electrónica autorizada por el SRI'),
                        criptoT('Inventario, compras y contabilidad al día'),
                        criptoT('Soporte técnico incluido con CRIPTO Support'),
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
                              child: Text(criptoT('Quiero conocerlo'),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(criptoT('Ahora no'),
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

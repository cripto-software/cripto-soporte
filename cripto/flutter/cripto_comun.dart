// ============================================================
// 📁 RUTA : cripto/flutter/cripto_comun.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_comun.dart)
// 📌 ARCHIVO: cripto_comun.dart
// 📝 RESUMEN: Piezas comunes de las pantallas CRIPTO Soporte: logo
//             oficial (la marca es la publicidad de CRIPTO), encabezado
//             con logo y nombre, botones uniformes (misma altura, radio
//             y relleno) y huella SHA-256 para guardar el PIN del dueño
//             sin guardarlo en texto.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  24/11/2026  Versión inicial (v1.2 de la app).
// ============================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'cripto_lopdp.dart';

/// Logo oficial; aplicar_marca.py lo copia a flutter/assets/ al compilar.
const String kCriptoLogoAsset = 'assets/cripto_logo.png';
const Color kCriptoAzulMarca = Color(0xFF2563EB);
const Color kCriptoFondo = Color(0xFFF8FAFC);
const Color kCriptoBorde = Color(0xFFE2E8F0);
const Color kCriptoRojo = Color(0xFFB91C1C);
const Color kCriptoVerde = Color(0xFF15803D);

const TextStyle kCriTitulo =
    TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kCriptoTexto);
const TextStyle kCriCuerpo =
    TextStyle(fontSize: 16, color: kCriptoTexto, height: 1.4);
const TextStyle kCriCuerpoNegrita =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kCriptoTexto);
const TextStyle kCriPequeno =
    TextStyle(fontSize: 14, color: kCriptoTexto, height: 1.4);

/// Une las palabras del teléfono para que nunca se corte en dos líneas.
String criptoSinCorte(String texto) => texto.replaceAll(' ', ' ');

class CriptoLogo extends StatelessWidget {
  final double lado;
  const CriptoLogo({Key? key, this.lado = 44}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(lado * 0.27),
      child: Image.asset(
        kCriptoLogoAsset,
        width: lado,
        height: lado,
        fit: BoxFit.cover,
        semanticLabel: 'Logo CRIPTO',
        errorBuilder: (_, __, ___) => Container(
          width: lado,
          height: lado,
          color: kCriptoAzulMarca,
          alignment: Alignment.center,
          child: const Text('C',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
        ),
      ),
    );
  }
}

/// Encabezado azul marino con logo, nombre y una línea de estado.
class CriptoEncabezado extends StatelessWidget {
  final String subtitulo;
  final List<Widget> acciones;
  const CriptoEncabezado(
      {Key? key, required this.subtitulo, this.acciones = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCriptoAzul,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 8, 16),
      child: Row(
        children: [
          const CriptoLogo(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CRIPTO Soporte',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text(subtitulo,
                    style: const TextStyle(
                        color: Color(0xFFE2E8F0), fontSize: 14)),
              ],
            ),
          ),
          ...acciones,
        ],
      ),
    );
  }
}

Widget criptoBotonPrincipal(String texto, VoidCallback? alPulsar,
    {Color fondo = kCriptoAzul, IconData? icono}) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: alPulsar,
      style: ElevatedButton.styleFrom(
        backgroundColor: fondo,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFCBD5E1),
        disabledForegroundColor: kCriptoTexto,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 24),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(texto,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ),
  );
}

Widget criptoBotonSecundario(String texto, VoidCallback alPulsar,
    {Color color = kCriptoAzul}) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: OutlinedButton(
      onPressed: alPulsar,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(texto,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: color)),
    ),
  );
}

/// Tarjeta blanca con borde suave, usada en todas las pantallas CRIPTO.
Widget criptoTarjeta(Widget hijo, {EdgeInsets? relleno}) {
  return Container(
    width: double.infinity,
    padding: relleno ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kCriptoBorde),
    ),
    child: hijo,
  );
}

// ------------------------------------------------------------
// SHA-256 (para el PIN del dueño; nunca se guarda el PIN en texto)
// ------------------------------------------------------------
const List<int> _k = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
  0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
  0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
  0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
  0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xFFFFFFFF;

String criptoSha256(String texto) {
  final mensaje = utf8.encode(texto);
  final largoBits = mensaje.length * 8;
  final relleno = <int>[...mensaje, 0x80];
  while (relleno.length % 64 != 56) {
    relleno.add(0);
  }
  for (var i = 7; i >= 0; i--) {
    relleno.add((largoBits >> (8 * i)) & 0xFF);
  }
  final h = <int>[
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];
  final bloque = Uint8List.fromList(relleno);
  final w = List<int>.filled(64, 0);
  for (var inicio = 0; inicio < bloque.length; inicio += 64) {
    for (var t = 0; t < 16; t++) {
      final j = inicio + t * 4;
      w[t] = (bloque[j] << 24) |
          (bloque[j + 1] << 16) |
          (bloque[j + 2] << 8) |
          bloque[j + 3];
    }
    for (var t = 16; t < 64; t++) {
      final s0 = _rotr(w[t - 15], 7) ^ _rotr(w[t - 15], 18) ^ (w[t - 15] >> 3);
      final s1 = _rotr(w[t - 2], 17) ^ _rotr(w[t - 2], 19) ^ (w[t - 2] >> 10);
      w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & 0xFFFFFFFF;
    }
    var a = h[0], b = h[1], c = h[2], d = h[3];
    var e = h[4], f = h[5], g = h[6], hh = h[7];
    for (var t = 0; t < 64; t++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e & 0xFFFFFFFF) & g);
      final t1 = (hh + s1 + ch + _k[t] + w[t]) & 0xFFFFFFFF;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final t2 = (s0 + maj) & 0xFFFFFFFF;
      hh = g;
      g = f;
      f = e;
      e = (d + t1) & 0xFFFFFFFF;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & 0xFFFFFFFF;
    }
    h[0] = (h[0] + a) & 0xFFFFFFFF;
    h[1] = (h[1] + b) & 0xFFFFFFFF;
    h[2] = (h[2] + c) & 0xFFFFFFFF;
    h[3] = (h[3] + d) & 0xFFFFFFFF;
    h[4] = (h[4] + e) & 0xFFFFFFFF;
    h[5] = (h[5] + f) & 0xFFFFFFFF;
    h[6] = (h[6] + g) & 0xFFFFFFFF;
    h[7] = (h[7] + hh) & 0xFFFFFFFF;
  }
  return h.map((v) => v.toRadixString(16).padLeft(8, '0')).join();
}

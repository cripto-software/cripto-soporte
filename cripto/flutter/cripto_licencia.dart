// ============================================================
// 📁 RUTA : cripto/flutter/cripto_licencia.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_licencia.dart)
// 📌 ARCHIVO: cripto_licencia.dart
// 📝 RESUMEN: Licencia de técnico en CRIPTO Soporte para Windows.
//             • Línea bajo «Dar soporte»: muestra si la licencia está
//               activa o un enlace «Activar licencia de técnico».
//             • Ventana de activación: el técnico escribe su código
//               CRS-XXXX-XXXX-XXXX y su nombre; el servidor de PCG SAS
//               ata la licencia a este equipo y entrega una credencial
//               que se guarda en la configuración local (el programa la
//               cifra en cuanto la usa). El código no se guarda.
//             Sin licencia el programa sigue funcionando entre PC (ver,
//             controlar y chat); la licencia habilita el soporte a
//             celulares y las funciones Pro.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  26/11/2026  Versión inicial.
//   v1.1  27/11/2026  El ID del equipo se envía como «idSoporte» (nombres CRIPTO).
//   v1.2  27/11/2026  Se guardan también los permisos de la licencia que envíe
//                     el servidor (permiteAudio, permiteArchivos,
//                     permiteGrabacion) para las funciones Pro (cripto_pro.dart).
//                     Si el servidor no los envía, la licencia activa habilita
//                     las tres funciones.
//   v1.3  27/11/2026  Textos en español e inglés (criptoT, cripto_idioma.dart)
//                     y nombre «CRIPTO Support».
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/platform_model.dart';
import 'cripto_idioma.dart';

const String kCriptoApiLicencia = 'https://api.criptosoftware.com/api/soporte/licencia';
const String kCriptoOpcionCredencial = 'cripto-credencial';
const String kCriptoOpcionLicenciaInfo = 'cripto-licencia-info';

const Color kCriptoLicAzul = Color(0xFF2563EB);
const Color kCriptoLicVerde = Color(0xFF15803D);
const Color kCriptoLicTexto = Color(0xFF0F172A);
const Color kCriptoLicError = Color(0xFFB91C1C);

/// Datos visibles de la licencia activada (sin secretos).
Map<String, dynamic>? criptoLicenciaInfo() {
  if (bind.mainGetLocalOption(key: kCriptoOpcionCredencial).isEmpty) return null;
  try {
    final v = jsonDecode(bind.mainGetLocalOption(key: kCriptoOpcionLicenciaInfo));
    return v is Map<String, dynamic> ? v : <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
}

/// Línea bajo el panel «Dar soporte».
class CriptoLicenciaTecnico extends StatefulWidget {
  const CriptoLicenciaTecnico({Key? key}) : super(key: key);

  @override
  State<CriptoLicenciaTecnico> createState() => _CriptoLicenciaTecnicoState();
}

class _CriptoLicenciaTecnicoState extends State<CriptoLicenciaTecnico> {
  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colorTexto = oscuro ? Colors.white : kCriptoLicTexto;
    final info = criptoLicenciaInfo();

    final Widget contenido;
    if (info != null) {
      final plan = (info['nombrePlan'] ?? info['plan'] ?? '').toString();
      final empresa = (info['nombreEmpresa'] ?? '').toString();
      contenido = Row(children: [
        const Icon(Icons.verified_user_outlined, size: 16, color: kCriptoLicVerde),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '${criptoT('Licencia de técnico activa')}'
            '${plan.isNotEmpty ? ' · $plan' : ''}'
            '${empresa.isNotEmpty ? ' · $empresa' : ''}',
            style: TextStyle(fontSize: 12, color: colorTexto),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]);
    } else {
      contenido = InkWell(
        onTap: () async {
          final activada = await criptoMostrarActivarLicencia(context);
          if (activada && mounted) setState(() {});
        },
        child: Row(children: [
          Icon(Icons.key_outlined, size: 16, color: kCriptoLicAzul),
          SizedBox(width: 6),
          Text(criptoT('Activar licencia de técnico'),
              style: TextStyle(fontSize: 12, color: kCriptoLicAzul)),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 12),
      child: contenido,
    );
  }
}

/// Ventana de activación. Devuelve true si la licencia quedó activada.
Future<bool> criptoMostrarActivarLicencia(BuildContext context) async {
  final r = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _VentanaActivar(),
  );
  return r == true;
}

class _VentanaActivar extends StatefulWidget {
  const _VentanaActivar();

  @override
  State<_VentanaActivar> createState() => _VentanaActivarState();
}

class _VentanaActivarState extends State<_VentanaActivar> {
  final _codigo = TextEditingController();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _activar() async {
    final codigo = _codigo.text.trim().toUpperCase();
    final nombre = _nombre.text.trim();
    if (!RegExp(r'^(CRS-?)?[A-Z0-9]{4}-?[A-Z0-9]{4}-?[A-Z0-9]{4}$').hasMatch(codigo)) {
      setState(() => _error = criptoT('Escriba el código completo: CRS-XXXX-XXXX-XXXX.'));
      return;
    }
    if (nombre.length < 3) {
      setState(() => _error = criptoT('Escriba el nombre del técnico.'));
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final miId = await bind.mainGetMyId();
      final resp = await http
          .post(
            Uri.parse('$kCriptoApiLicencia/activar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'codigo': codigo,
              'idSoporte': miId,
              'nombreTecnico': nombre,
              'correo': _correo.text.trim(),
              'nombreEquipo': Platform.localHostname,
            }),
          )
          .timeout(const Duration(seconds: 20));
      final cuerpo = jsonDecode(utf8.decode(resp.bodyBytes));
      if (resp.statusCode == 200 && cuerpo is Map && cuerpo['success'] == true) {
        final data = cuerpo['data'] as Map;
        final credencial = (data['credencial'] ?? '').toString();
        if (credencial.length != 64) {
          throw Exception(criptoT('Respuesta incompleta del servidor.'));
        }
        await bind.mainSetLocalOption(key: kCriptoOpcionCredencial, value: credencial);
        await bind.mainSetLocalOption(
            key: kCriptoOpcionLicenciaInfo,
            value: jsonEncode({
              'plan': data['plan'],
              'nombrePlan': data['nombrePlan'],
              'nombreTecnico': data['nombreTecnico'],
              'nombreEmpresa': data['nombreEmpresa'],
              'fechaFin': data['fechaFin']?.toString(),
              // v1.2 — Permisos de las funciones Pro (null = permitido).
              'permiteAudio': data['permiteAudio'],
              'permiteArchivos': data['permiteArchivos'],
              'permiteGrabacion': data['permiteGrabacion'],
            }));
        debugPrint('[CRIPTO] Licencia de técnico activada en este equipo');
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
      setState(() => _error = (cuerpo is Map ? cuerpo['message'] : null)?.toString() ??
          criptoT('No se pudo activar la licencia ({codigo}).', {'codigo': resp.statusCode}));
    } catch (e) {
      debugPrint('[CRIPTO] Error al activar la licencia: ${e.runtimeType}');
      setState(() => _error =
          criptoT('No se pudo conectar con CRIPTO. Revise su internet e intente de nuevo.'));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  InputDecoration _campo(String etiqueta, String ejemplo) => InputDecoration(
        labelText: etiqueta,
        hintText: ejemplo,
        isDense: true,
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(criptoT('Activar licencia de técnico'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              criptoT('Escriba el código de licencia que le entregó CRIPTO. La licencia queda activada solo en este equipo.'),
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codigo,
              enabled: !_enviando,
              textCapitalization: TextCapitalization.characters,
              decoration: _campo(criptoT('Código de licencia'), 'CRS-XXXX-XXXX-XXXX'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombre,
              enabled: !_enviando,
              decoration: _campo(criptoT('Nombre del técnico'), criptoT('Nombre y apellido')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _correo,
              enabled: !_enviando,
              keyboardType: TextInputType.emailAddress,
              decoration: _campo(criptoT('Correo (opcional)'), 'tecnico@empresa.com'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(fontSize: 13, color: kCriptoLicError)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(false),
          child: Text(criptoT('Cancelar')),
        ),
        ElevatedButton(
          onPressed: _enviando ? null : _activar,
          style: ElevatedButton.styleFrom(backgroundColor: kCriptoLicAzul),
          child: _enviando
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(criptoT('Activar'), style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

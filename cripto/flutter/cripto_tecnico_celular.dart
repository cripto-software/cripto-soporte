// ============================================================
// 📁 RUTA : cripto/flutter/cripto_tecnico_celular.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_tecnico_celular.dart)
// 📌 ARCHIVO: cripto_tecnico_celular.dart
// 📝 RESUMEN: Modo «Soy técnico» del celular (fase 2 de CRIPTO Support).
//             Permite dar soporte desde el celular a otros celulares y a
//             computadoras, SOLO con licencia de técnico activa (PCG y
//             técnicos registrados con CRIPTO Pro).
//             • Sin licencia: explica el modo técnico y ofrece activar la
//               licencia o pedirla por WhatsApp. Pedir ayuda sigue libre.
//             • Con licencia: elección Técnico / Acompañante (solo mirar),
//               número del cliente, Conectar y la lista de equipos recientes.
//               Opción para cerrar la licencia en este celular.
//             La pantalla es la primera puerta; la segunda está en el
//             equipo que recibe la conexión: el celular o la PC del cliente
//             solo deja entrar a un técnico con pase válido del servidor de
//             licencias de PCG S.A.S. (aunque alguien modifique esta app).
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  28/11/2026  Versión inicial (fase 2: modo técnico en el celular).
// ============================================================

import 'dart:convert';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common.dart';
import '../models/platform_model.dart';
import 'cripto_comun.dart';
import 'cripto_idioma.dart';
import 'cripto_licencia.dart';
import 'cripto_lopdp.dart';
import 'cripto_tecnico.dart';

/// Opción local con los equipos a los que este técnico se conectó.
const String kCriptoOpcionRecientes = 'cripto-tecnico-recientes';

/// WhatsApp de PCG S.A.S. para pedir la licencia de técnico.
const String kCriptoWhatsAppTecnico = '593985666807';

/// Mínimo de dígitos de un número de CRIPTO Support.
const int kCriptoMinimoDigitos = 6;

/// Un equipo al que el técnico se conectó.
class CriptoReciente {
  final String id;
  final String fecha; // ISO 8601
  const CriptoReciente(this.id, this.fecha);

  Map<String, dynamic> aJson() => {'id': id, 'fecha': fecha};
}

/// Lista de recientes (la más nueva primero).
List<CriptoReciente> criptoLeerRecientes() {
  try {
    final v = jsonDecode(bind.mainGetLocalOption(key: kCriptoOpcionRecientes));
    if (v is! List) return [];
    return v
        .whereType<Map>()
        .map((m) => CriptoReciente(
            criptoSoloDigitosTecnico('${m['id'] ?? ''}'), '${m['fecha'] ?? ''}'))
        .where((r) => r.id.isNotEmpty)
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> _guardarRecientes(List<CriptoReciente> lista) async {
  await bind.mainSetLocalOption(
      key: kCriptoOpcionRecientes,
      value: jsonEncode(lista.map((r) => r.aJson()).toList()));
}

/// Agrega (o sube al inicio) un equipo en la lista de recientes.
Future<void> criptoAgregarReciente(String id) async {
  final limpio = criptoSoloDigitosTecnico(id);
  if (limpio.isEmpty) return;
  final lista = criptoLeerRecientes().where((r) => r.id != limpio).toList();
  lista.insert(0, CriptoReciente(limpio, DateTime.now().toIso8601String()));
  await _guardarRecientes(lista);
}

String criptoSoloDigitosTecnico(String id) => id.replaceAll(RegExp(r'[^0-9]'), '');

/// 123456789 → «123 456 789» (para leerlo fácil en voz alta).
String criptoFormatoNumero(String id) {
  final d = criptoSoloDigitosTecnico(id);
  final partes = <String>[];
  for (var i = 0; i < d.length; i += 3) {
    partes.add(d.substring(i, i + 3 > d.length ? d.length : i + 3));
  }
  return partes.join(' ');
}

// ------------------------------------------------------------
// Pantalla: Soy técnico
// ------------------------------------------------------------
class CriptoSoyTecnicoPage extends StatefulWidget {
  const CriptoSoyTecnicoPage({Key? key}) : super(key: key);

  @override
  State<CriptoSoyTecnicoPage> createState() => _CriptoSoyTecnicoPageState();
}

class _CriptoSoyTecnicoPageState extends State<CriptoSoyTecnicoPage> {
  final TextEditingController _numero = TextEditingController();
  late String _rol;
  bool _conectando = false;

  @override
  void initState() {
    super.initState();
    _rol = criptoRolActual();
    debugPrint('[CRIPTO] Soy técnico: pantalla abierta '
        '(licencia ${criptoLicenciaInfo() != null ? 'activa' : 'no activa'})');
  }

  @override
  void dispose() {
    _numero.dispose();
    super.dispose();
  }

  Future<void> _activar() async {
    final ok = await criptoMostrarActivarLicencia(context);
    debugPrint('[CRIPTO] Soy técnico: activación ${ok ? 'correcta' : 'cancelada'}');
    if (mounted) setState(() {});
  }

  Future<void> _pedirLicencia() async {
    final texto = Uri.encodeComponent(criptoT('Hola, quiero ser técnico de CRIPTO Support.'));
    try {
      await launchUrl(Uri.parse('https://wa.me/$kCriptoWhatsAppTecnico?text=$texto'),
          mode: LaunchMode.externalApplication);
      debugPrint('[CRIPTO] Soy técnico: se abrió WhatsApp para pedir licencia');
    } catch (e) {
      debugPrint('[CRIPTO] Soy técnico: no se pudo abrir WhatsApp (${e.runtimeType})');
    }
  }

  Future<void> _elegirRol(String rol) async {
    setState(() => _rol = rol);
    await bind.mainSetLocalOption(key: kCriptoOpcionRol, value: rol);
    debugPrint('[CRIPTO] Soy técnico: rol elegido $rol');
  }

  Future<void> _conectar([String? numero]) async {
    if (_conectando) return;
    final id = criptoSoloDigitosTecnico(numero ?? _numero.text);
    if (id.length < kCriptoMinimoDigitos) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(criptoT('Escribe el número completo del cliente.'))));
      return;
    }
    final miId = criptoSoloDigitosTecnico(gFFI.serverModel.serverId.text);
    if (miId.isNotEmpty && id == miId) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(criptoT('Ese es el número de este celular. Escribe el del cliente.'))));
      return;
    }
    // La licencia pudo cerrarse en otra pantalla: se vuelve a revisar.
    if (criptoLicenciaInfo() == null) {
      setState(() {});
      return;
    }
    setState(() => _conectando = true);
    debugPrint('[CRIPTO] Soy técnico: conectando como $_rol');
    try {
      await criptoAgregarReciente(id);
      if (!mounted) return;
      _numero.text = criptoFormatoNumero(id);
      await connect(context, id);
    } finally {
      if (mounted) setState(() => _conectando = false);
    }
  }

  Future<void> _quitarReciente(CriptoReciente r) async {
    final lista = criptoLeerRecientes().where((x) => x.id != r.id).toList();
    await _guardarRecientes(lista);
    if (mounted) setState(() {});
  }

  Future<void> _cerrarLicencia() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(criptoT('¿Cerrar la licencia en este celular?'), style: kCriTitulo),
        content: Text(
            criptoT('Este celular dejará de dar soporte como técnico. Podrás activarla de nuevo con tu código.'),
            style: kCriCuerpo),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(criptoT('Cancelar'), style: kCriCuerpoNegrita)),
          TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(criptoT('Cerrar licencia'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: kCriptoRojo))),
        ],
      ),
    );
    if (ok != true) return;
    await criptoCerrarLicencia();
    debugPrint('[CRIPTO] Soy técnico: licencia cerrada en este celular');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(criptoT('Licencia cerrada en este celular.'))));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final info = criptoLicenciaInfo();
    return Scaffold(
      backgroundColor: kCriptoFondo,
      body: Column(
        children: [
          CriptoEncabezado(subtitulo: criptoT('Modo técnico'), acciones: [
            CriptoBotonIdioma(color: Colors.white, alCambiar: () => setState(() {})),
            IconButton(
              tooltip: criptoT('Volver'),
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
          Expanded(child: info == null ? _vistaSinLicencia() : _vistaTecnico(info)),
        ],
      ),
    );
  }

  // ---------------- Sin licencia ----------------
  Widget _vistaSinLicencia() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        Text(criptoT('¿Eres técnico de CRIPTO?'), style: kCriTitulo),
        const SizedBox(height: 12),
        Text(
            criptoT('El modo técnico permite dar soporte desde este celular a otros celulares y computadoras. Es solo para el equipo de PCG S.A.S. y técnicos registrados con licencia CRIPTO Pro.'),
            style: kCriCuerpo),
        const SizedBox(height: 20),
        criptoTarjeta(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_user_outlined, size: 24, color: kCriptoAzul),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    criptoT('Por seguridad, los equipos de los clientes solo aceptan a técnicos con licencia válida. Cada conexión queda registrada.'),
                    style: kCriCuerpo)),
          ],
        )),
        const SizedBox(height: 20),
        criptoBotonPrincipal(criptoT('Activar licencia de técnico'), _activar,
            icono: Icons.key_outlined),
        const SizedBox(height: 12),
        criptoBotonSecundario(criptoT('Quiero ser técnico (WhatsApp)'), _pedirLicencia,
            color: kCriptoVerde),
        const SizedBox(height: 20),
        Text(criptoT('Si solo necesitas ayuda, vuelve y toca «Pedir ayuda».'),
            textAlign: TextAlign.center, style: kCriPequeno),
      ],
    );
  }

  // ---------------- Con licencia ----------------
  Widget _vistaTecnico(Map<String, dynamic> info) {
    final plan = (info['nombrePlan'] ?? info['plan'] ?? '').toString();
    final empresa = (info['nombreEmpresa'] ?? '').toString();
    final tecnico = (info['nombreTecnico'] ?? '').toString();
    final recientes = criptoLeerRecientes();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        // Licencia activa
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user, size: 24, color: kCriptoVerde),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(criptoT('Licencia de técnico activa'), style: kCriCuerpoNegrita),
                    if (tecnico.isNotEmpty) Text(tecnico, style: kCriPequeno),
                    if (plan.isNotEmpty || empresa.isNotEmpty)
                      Text([plan, empresa].where((t) => t.isNotEmpty).join(' · '),
                          style: kCriPequeno),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Rol
        Text(criptoT('Conectarme como'), style: kCriCuerpoNegrita),
        const SizedBox(height: 8),
        _opcionRol(kCriptoRolTecnico, Icons.touch_app_outlined, criptoT('Técnico'),
            criptoT('Ver y controlar el equipo')),
        const SizedBox(height: 8),
        _opcionRol(kCriptoRolAcompanante, Icons.visibility_outlined, criptoT('Acompañante'),
            criptoT('Solo mirar, sin tocar nada')),
        const SizedBox(height: 20),

        // Número del cliente
        TextField(
          controller: _numero,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.go,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: kCriptoTexto,
              letterSpacing: 2,
              fontFeatures: [FontFeature.tabularFigures()]),
          decoration: InputDecoration(
            labelText: criptoT('Número del cliente'),
            hintText: '123 456 789',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _conectar(),
        ),
        const SizedBox(height: 12),
        criptoBotonPrincipal(
            _conectando ? criptoT('Conectando…') : criptoT('Conectar'),
            _conectando ? null : () => _conectar(),
            icono: Icons.link),
        const SizedBox(height: 12),
        Text(
            criptoT('El cliente debe aceptar la conexión en su equipo. Cada sesión queda registrada.'),
            style: kCriPequeno),
        const SizedBox(height: 24),

        // Recientes
        Text(criptoT('Recientes'), style: kCriCuerpoNegrita),
        const SizedBox(height: 8),
        if (recientes.isEmpty)
          Text(criptoT('Todavía no te has conectado a ningún equipo.'), style: kCriPequeno)
        else
          criptoTarjeta(
            Column(
              children: [
                for (var i = 0; i < recientes.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: kCriptoBorde),
                  _filaReciente(recientes[i]),
                ],
              ],
            ),
            relleno: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        const SizedBox(height: 32),
        Center(
          child: TextButton.icon(
            onPressed: _cerrarLicencia,
            icon: const Icon(Icons.logout, size: 20, color: kCriptoRojo),
            label: Text(criptoT('Cerrar mi licencia en este celular'),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: kCriptoRojo)),
          ),
        ),
      ],
    );
  }

  Widget _opcionRol(String valor, IconData icono, String titulo, String detalle) {
    final elegido = _rol == valor;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _elegirRol(valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: elegido ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: elegido ? kCriptoAzul : kCriptoBorde, width: 2),
        ),
        child: Row(
          children: [
            Icon(icono, size: 24, color: kCriptoAzul),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: kCriCuerpoNegrita),
                  Text(detalle, style: kCriPequeno),
                ],
              ),
            ),
            Icon(elegido ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 24, color: kCriptoAzul),
          ],
        ),
      ),
    );
  }

  Widget _filaReciente(CriptoReciente r) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const Icon(Icons.devices_outlined, size: 24, color: kCriptoAzul),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _conectar(r.id),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(criptoFormatoNumero(r.id),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kCriptoTexto,
                          fontFeatures: [FontFeature.tabularFigures()])),
                  Text(_fecha(r.fecha), style: kCriPequeno),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: criptoT('Conectar'),
            icon: const Icon(Icons.link, size: 24, color: kCriptoAzul),
            onPressed: _conectando ? null : () => _conectar(r.id),
          ),
          IconButton(
            tooltip: criptoT('Quitar'),
            icon: const Icon(Icons.delete_outline, size: 24, color: kCriptoRojo),
            onPressed: () => _quitarReciente(r),
          ),
        ],
      ),
    );
  }

  String _fecha(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(d.day)}/${dos(d.month)}/${d.year} ${dos(d.hour)}:${dos(d.minute)}';
  }
}

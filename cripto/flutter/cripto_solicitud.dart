// ============================================================
// 📁 RUTA : cripto/flutter/cripto_solicitud.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_solicitud.dart)
// 📌 ARCHIVO: cripto_solicitud.dart
// 📝 RESUMEN: Reemplaza la ventana «¿Aceptas?» original del motor de conexión. Cada
//             conexión la acepta SIEMPRE el dueño del celular y elige el
//             rol: Técnico (ve y controla) o Acompañante (solo mira: se le
//             apagan teclado, táctil, portapapeles y archivos SOLO a esa
//             conexión). Respeta el acompañamiento obligatorio de Empresa
//             y deja todo en el registro de sesiones.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  24/11/2026  Versión inicial (v1.2 de la app).
//   v1.1  27/11/2026  Textos en español e inglés (criptoT, cripto_idioma.dart)
//                     y nombre «CRIPTO Support».
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../common.dart';
import '../models/platform_model.dart';
import '../models/server_model.dart';
import 'cripto_acompanantes.dart';
import 'cripto_comun.dart';
import 'cripto_lopdp.dart';
import 'cripto_idioma.dart';

const String kRolTecnico = 'tecnico';
const String kRolAcompanante = 'acompanante';

/// Rol y nombre de cada conexión aceptada (por id interno de conexión).
class CriptoSesion {
  static final Map<int, String> roles = {};
  static final Map<int, String> etiquetas = {};
  static Timer? _guardia;

  static String rolDe(int connId) => roles[connId] ?? kRolTecnico;
  static String etiquetaDe(Client c) =>
      etiquetas[c.id] ?? (c.name.isNotEmpty ? c.name : criptoT('N.º {id}', {'id': c.peerId}));

  /// Apaga el control solo a esa conexión: el acompañante únicamente mira.
  static void _soloMirar(int connId) {
    for (final permiso in const ['keyboard', 'clipboard', 'file']) {
      bind.cmSwitchPermission(connId: connId, name: permiso, enabled: false);
    }
  }

  static void marcarAcompanante(int connId) {
    roles[connId] = kRolAcompanante;
    _soloMirar(connId);
    debugPrint('[CRIPTO] Conexión $connId en modo acompañante (solo mira)');
    // Guardia: si algún interruptor general vuelve a dar control a todos,
    // se le quita de nuevo al acompañante.
    _guardia ??= Timer.periodic(const Duration(seconds: 2), (_) {
      final activos = gFFI.serverModel.clients
          .where((c) => !c.disconnected)
          .map((c) => c.id)
          .toSet();
      roles.removeWhere((id, _) => !activos.contains(id));
      etiquetas.removeWhere((id, _) => !activos.contains(id));
      var hayAcompanantes = false;
      for (final c in gFFI.serverModel.clients) {
        if (c.disconnected || roles[c.id] != kRolAcompanante) continue;
        hayAcompanantes = true;
        if (c.keyboard || c.clipboard || c.file) _soloMirar(c.id);
      }
      if (!hayAcompanantes) {
        _guardia?.cancel();
        _guardia = null;
      }
    });
  }

  static bool hayAcompananteDeLista(CriptoConfigAcompanantes cfg) {
    return gFFI.serverModel.clients.any((c) =>
        c.authorized &&
        !c.disconnected &&
        roles[c.id] == kRolAcompanante &&
        cfg.buscar(c.peerId) != null);
  }
}

String _iniciales(String nombre) {
  final partes =
      nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (partes.isEmpty) return '?';
  final a = partes.first.characters.first.toUpperCase();
  final b = partes.length > 1 ? partes[1].characters.first.toUpperCase() : '';
  return '$a$b';
}

Widget _opcion({
  required IconData icono,
  required String titulo,
  required String detalle,
  required VoidCallback? alPulsar,
  bool destacado = false,
}) {
  final activo = alPulsar != null;
  return Material(
    color: destacado ? const Color(0xFFEFF6FF) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
          color: destacado ? kCriptoAzulMarca : const Color(0xFFCBD5E1),
          width: 2),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: alPulsar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icono,
                  size: 28,
                  color: activo ? kCriptoAzul : const Color(0xFF64748B)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kCriptoTexto)),
                    const SizedBox(height: 2),
                    Text(detalle, style: kCriPequeno),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Ventana de solicitud CRIPTO. La llama ServerModel.showLoginDialog.
void criptoSolicitudConexion(ServerModel modelo, Client client) {
  final cfg = CriptoConfigAcompanantes.cargar();
  final persona = cfg.buscar(client.peerId);
  final soloTecnico =
      client.isFileTransfer || client.isTerminal || client.isViewCamera;
  final tecnicoBloqueado =
      cfg.exigeAcompanante && !CriptoSesion.hayAcompananteDeLista(cfg);
  final nombre = client.name.isNotEmpty ? client.name : criptoT('Sin nombre');
  final que = client.isFileTransfer
      ? criptoT('Quiere pasar archivos a tu celular.')
      : client.isTerminal
          ? criptoT('Quiere abrir una terminal en tu celular.')
          : client.isViewCamera
              ? criptoT('Quiere ver tu cámara.')
              : criptoT('Quiere ver tu pantalla. ¿Cómo lo dejas entrar?');
  debugPrint('[CRIPTO] Solicitud de conexión ${client.id} '
      '(de lista: ${persona != null}, bloqueo técnico: $tecnicoBloqueado)');

  modelo.parent.target?.dialogManager.show((setState, close, context) {
    Future<void> tecnico() async {
      close();
      modelo.sendLoginResponse(client, true);
      CriptoSesion.roles[client.id] = kRolTecnico;
      CriptoSesion.etiquetas[client.id] = '$nombre · ${criptoT('Técnico')}';
      await CriptoRegistro.agregar(
          evento: 'Aceptado como técnico',
          id: client.peerId,
          nombre: nombre,
          rol: criptoT('Técnico'));
    }

    Future<void> acompanante() async {
      close();
      modelo.sendLoginResponse(client, true);
      CriptoSesion.marcarAcompanante(client.id);
      final etiqueta = persona != null
          ? '${persona.nombre} · ${criptoT(persona.rol)}'
          : '$nombre · ${criptoT('Acompañante')}';
      CriptoSesion.etiquetas[client.id] = etiqueta;
      await CriptoRegistro.agregar(
          evento: 'Aceptado como acompañante (solo mira)',
          id: client.peerId,
          nombre: persona?.nombre ?? nombre,
          rol: persona?.rol ?? criptoT('Acompañante'));
    }

    Future<void> rechazar() async {
      close();
      modelo.sendLoginResponse(client, false);
      await CriptoRegistro.agregar(
          evento: 'Conexión rechazada', id: client.peerId, nombre: nombre);
    }

    final opTecnico = _opcion(
      icono: Icons.build_outlined,
      titulo: criptoT('Técnico'),
      detalle: tecnicoBloqueado
          ? criptoT('Primero debe conectarse un acompañante de tu lista (obligatorio).')
          : criptoT('Puede ver y controlar mi celular.'),
      alPulsar: tecnicoBloqueado ? null : tecnico,
      destacado: persona == null && !tecnicoBloqueado,
    );
    final opAcompanante = _opcion(
      icono: Icons.visibility_outlined,
      titulo: criptoT('Acompañante'),
      detalle: persona != null
          ? '${persona.nombre} · ${criptoT(persona.rol)}. ${criptoT('Solo puede mirar.')}'
          : criptoT('Solo puede mirar, no toca nada.'),
      alPulsar: acompanante,
      destacado: persona != null || tecnicoBloqueado,
    );

    return CustomAlertDialog(
      title: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: kCriptoAzul, shape: BoxShape.circle),
            child: Text(_iniciales(nombre),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: kCriTitulo),
                Text(criptoT('N.º {id}', {'id': client.peerId}), style: kCriPequeno),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(que, style: kCriCuerpoNegrita),
          const SizedBox(height: 12),
          if (soloTecnico) ...[
            opTecnico,
          ] else if (persona != null || tecnicoBloqueado) ...[
            opAcompanante,
            const SizedBox(height: 8),
            opTecnico,
          ] else ...[
            opTecnico,
            const SizedBox(height: 8),
            opAcompanante,
          ],
          const SizedBox(height: 12),
          criptoBotonSecundario(criptoT('Rechazar'), rechazar, color: kCriptoRojo),
          const SizedBox(height: 12),
          Text(
            criptoT('Si no conoces a esta persona, toca «Rechazar». CRIPTO nunca te pedirá claves del banco. Soporte oficial: {telefono}.', {'telefono': criptoSinCorte(kCriptoTelefono)}),
            style: kCriPequeno,
          ),
        ],
      ),
      onCancel: rechazar,
    );
  }, tag: getLoginDialogTag(client.id));
}

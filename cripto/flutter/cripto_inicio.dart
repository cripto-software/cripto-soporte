// ============================================================
// 📁 RUTA : cripto/flutter/cripto_inicio.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_inicio.dart)
// 📌 ARCHIVO: cripto_inicio.dart
// 📝 RESUMEN: Pantalla principal de CRIPTO Soporte, pensada primero para
//             el adulto mayor: un botón grande «Pedir ayuda», luego el
//             número de soporte en grande (con envío por WhatsApp) y,
//             durante la sesión, quién está mirando (técnico o
//             acompañante) con botón para sacar a cada uno. El logo y el
//             nombre CRIPTO van siempre visibles. «Más opciones» abre la
//             pantalla completa (modo avanzado).
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  24/11/2026  Versión inicial (v1.2 de la app).
//   v1.1  24/11/2026  App v1.3: «Enviar por WhatsApp» abre directo el chat
//                     de soporte de CRIPTO (098 566 6807) con el mensaje
//                     listo; el cliente solo pulsa enviar.
//   v1.2  27/11/2026  Textos en español e inglés (criptoT, cripto_idioma.dart)
//                     y nombre «CRIPTO Support». Botón «Idioma» en el encabezado.
// ============================================================

import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common.dart';
import '../consts.dart';
import '../mobile/pages/home_page.dart';
import '../models/platform_model.dart';
import '../models/server_model.dart';
import 'cripto_acompanantes.dart';
import 'cripto_avisos.dart';
import 'cripto_comun.dart';
import 'cripto_lopdp.dart';
import 'cripto_solicitud.dart';
import 'cripto_idioma.dart';

class CriptoInicioPage extends StatefulWidget {
  const CriptoInicioPage({Key? key}) : super(key: key);

  @override
  State<CriptoInicioPage> createState() => _CriptoInicioPageState();
}

class _CriptoInicioPageState extends State<CriptoInicioPage> {
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    criptoAplicarSeguridad();
    _reloj = Timer.periodic(const Duration(seconds: 3), (_) async {
      await gFFI.serverModel.fetchID();
    });
    gFFI.serverModel.fetchID();
    gFFI.serverModel.checkAndroidPermission();
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  Future<void> _pedirAyuda(ServerModel modelo) async {
    debugPrint('[CRIPTO] Pedir ayuda');
    await CriptoRegistro.agregar(evento: 'Pidió ayuda');
    if (!mounted) return;
    if (bind.mainGetLocalOption(key: 'show-scam-warning') != 'N') {
      await showDialog(
        context: context,
        builder: (_) => CriptoAvisoSeguridad(serverModel: modelo),
      );
    } else {
      await modelo.toggleService();
    }
  }

  Future<void> _terminar(ServerModel modelo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(criptoT('¿Terminar la ayuda?'), style: kCriTitulo),
        content: Text(
            criptoT('Se desconectará a todos y nadie podrá ver tu pantalla.'),
            style: kCriCuerpo),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(criptoT('Seguir'), style: kCriCuerpoNegrita)),
          TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(criptoT('Terminar'), style: kCriCuerpoNegrita)),
        ],
      ),
    );
    if (ok != true) return;
    await modelo.stopService();
    await CriptoRegistro.agregar(evento: 'Terminó la ayuda');
  }

  Future<void> _sacar(Client c) async {
    final etiqueta = CriptoSesion.etiquetaDe(c);
    bind.cmCloseConnection(connId: c.id);
    await CriptoRegistro.agregar(
        evento: 'Sacó a una persona de la sesión',
        id: c.peerId,
        nombre: etiqueta);
  }

  /// v1.1 — Número de WhatsApp de soporte en formato internacional
  /// (Ecuador 593 + número sin el 0 inicial), sacado de kCriptoTelefono.
  String _numeroWhatsAppSoporte() {
    var digitos = kCriptoTelefono.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.startsWith('0')) digitos = digitos.substring(1);
    return '593$digitos';
  }

  Future<void> _enviarWhatsApp(String id) async {
    final texto = Uri.encodeComponent(
        criptoT('Hola, necesito ayuda. Mi número de CRIPTO Support es {id}', {'id': id}));
    try {
      // v1.1 — Directo al chat de soporte de CRIPTO.
      await launchUrl(
          Uri.parse('https://wa.me/${_numeroWhatsAppSoporte()}?text=$texto'),
          mode: LaunchMode.externalApplication);
      debugPrint('[CRIPTO] WhatsApp abierto hacia soporte');
    } catch (e) {
      debugPrint('[CRIPTO] No se pudo abrir WhatsApp: $e');
    }
  }

  void _abrir(Widget pagina) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pagina));
  }

  Widget _menu() {
    return PopupMenuButton<String>(
      tooltip: criptoT('Opciones'),
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
      onSelected: (v) {
        switch (v) {
          case 'acompanantes':
            _abrir(const CriptoAcompanantesPage());
            break;
          case 'historial':
            _abrir(const CriptoRegistroPage());
            break;
          case 'privacidad':
            criptoMostrarPrivacidad(context);
            break;
          case 'avanzado':
            _abrir(HomePage());
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
            value: 'acompanantes',
            child: Text(criptoT('Persona de confianza'), style: kCriCuerpo)),
        PopupMenuItem(
            value: 'historial',
            child: Text(criptoT('Historial de sesiones'), style: kCriCuerpo)),
        PopupMenuItem(
            value: 'privacidad',
            child: Text(criptoT('Aviso de privacidad'), style: kCriCuerpo)),
        PopupMenuItem(
            value: 'avanzado', child: Text(criptoT('Más opciones'), style: kCriCuerpo)),
      ],
    );
  }

  Widget _vistaInicial(ServerModel modelo) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        Text(criptoT('¿Necesitas ayuda con tu celular?'),
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: kCriptoTexto,
                height: 1.2)),
        const SizedBox(height: 8),
        Text(
            criptoT('Toca el botón y dile el número que aparece a tu técnico de CRIPTO.'),
            style: TextStyle(fontSize: 17, color: kCriptoTexto, height: 1.5)),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: ElevatedButton(
            onPressed: () => _pedirAyuda(modelo),
            style: ElevatedButton.styleFrom(
              backgroundColor: kCriptoAzulMarca,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.headset_mic, size: 64),
                SizedBox(height: 12),
                Text(criptoT('Pedir ayuda'),
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text(criptoT('Iniciar soporte remoto'),
                    style: TextStyle(fontSize: 15, color: Color(0xFFDBEAFE))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        criptoTarjeta(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shield_outlined, size: 24, color: kCriptoAzul),
            SizedBox(width: 12),
            Expanded(
                child: Text(
                    criptoT('Nadie puede entrar sin que tú lo aceptes. Puedes cortar la ayuda cuando quieras.'),
                    style: kCriCuerpo)),
          ],
        )),
        const SizedBox(height: 20),
        criptoBotonSecundario(criptoT('Persona de confianza'),
            () => _abrir(const CriptoAcompanantesPage())),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: criptoT('Un servicio de ')),
            TextSpan(
                text: criptoT('CRIPTO Software'),
                style: TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: criptoT(' · pc-green.com')),
          ]),
          textAlign: TextAlign.center,
          style: kCriPequeno,
        ),
      ],
    );
  }

  Widget _vistaEsperando(ServerModel modelo) {
    final id = modelo.serverId.text;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        Text(criptoT('Dile este número a tu técnico:'),
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: kCriptoTexto)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kCriptoAzulMarca, width: 2),
          ),
          child: Column(
            children: [
              FittedBox(
                child: Text(id.isEmpty ? '…' : id,
                    style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: kCriptoTexto,
                        fontFeatures: [FontFeature.tabularFigures()])),
              ),
              const SizedBox(height: 4),
              Text(criptoT('Tu número de soporte'), style: kCriPequeno),
            ],
          ),
        ),
        const SizedBox(height: 16),
        criptoBotonPrincipal(
            criptoT('Enviar por WhatsApp'), id.isEmpty ? null : () => _enviarWhatsApp(id),
            fondo: kCriptoVerde, icono: Icons.chat_outlined),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Icon(Icons.hourglass_top, size: 24, color: kCriptoAzul),
              SizedBox(width: 12),
              Expanded(
                  child: Text(
                      criptoT('Cuando el técnico se conecte, te preguntaremos si lo aceptas.'),
                      style: kCriCuerpo)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        criptoBotonSecundario(criptoT('Cancelar'), () => _terminar(modelo)),
      ],
    );
  }

  Widget _vistaSesion(ServerModel modelo, List<Client> activos) {
    final hayTecnico =
        activos.any((c) => CriptoSesion.rolDe(c.id) == kRolTecnico);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        criptoTarjeta(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(criptoT('Te están viendo'), style: kCriCuerpoNegrita),
            const SizedBox(height: 8),
            for (final c in activos)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                        CriptoSesion.rolDe(c.id) == kRolAcompanante
                            ? Icons.visibility_outlined
                            : Icons.build_outlined,
                        size: 24,
                        color: kCriptoAzul),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(CriptoSesion.etiquetaDe(c),
                              style: kCriCuerpoNegrita),
                          Text(
                              CriptoSesion.rolDe(c.id) == kRolAcompanante
                                  ? criptoT('Solo mira')
                                  : criptoT('Puede controlar tu celular'),
                              style: kCriPequeno),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => _sacar(c),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kCriptoRojo,
                          side: const BorderSide(color: kCriptoRojo),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(criptoT('Sacar'),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        )),
        if (hayTecnico && !modelo.inputOk) ...[
          const SizedBox(height: 16),
          criptoBotonPrincipal(criptoT('Permitir que el técnico toque mi pantalla'),
              () => modelo.toggleInput(),
              icono: Icons.touch_app_outlined),
          const SizedBox(height: 8),
          Text(
              criptoT('Solo si el técnico te lo pide. Mientras tanto él solo puede mirar y guiarte.'),
              style: kCriPequeno),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Text(
              criptoT('Para escribir una clave, pide al técnico que espere. En Android 15 o superior las claves se ocultan solas. Nunca dictes claves.'),
              style: kCriCuerpo),
        ),
        const SizedBox(height: 24),
        criptoBotonPrincipal(criptoT('Terminar ayuda'), () => _terminar(modelo),
            fondo: kCriptoRojo),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Consumer<ServerModel>(builder: (context, modelo, _) {
        final activos = modelo.clients
            .where((c) => c.authorized && !c.disconnected)
            .toList();
        final Widget cuerpo;
        final String estado;
        if (!modelo.isStart) {
          cuerpo = _vistaInicial(modelo);
          estado = criptoT('Soporte de CRIPTO Software');
        } else if (activos.isEmpty) {
          cuerpo = _vistaEsperando(modelo);
          estado = criptoT('Esperando al técnico…');
        } else {
          cuerpo = _vistaSesion(modelo, activos);
          estado = criptoT('Soporte en curso');
        }
        return Scaffold(
          backgroundColor: kCriptoFondo,
          body: Column(
            children: [
              CriptoEncabezado(subtitulo: estado, acciones: [
                CriptoBotonIdioma(
                    color: Colors.white, alCambiar: () => setState(() {})),
                _menu(),
              ]),
              Expanded(child: cuerpo),
            ],
          ),
        );
      }),
    );
  }
}

/// Reglas de seguridad de CRIPTO que se aplican al abrir la app:
/// toda conexión se acepta con un toque (nunca entra nadie solo con la
/// contraseña) y no se pide la carpeta de registros del motor de conexión.
void criptoAplicarSeguridad() {
  if (gFFI.serverModel.approveMode != 'click') {
    bind.mainSetOption(key: kOptionApproveMode, value: 'click');
    debugPrint('[CRIPTO] Aceptación de conexiones: siempre con un toque');
  }
}

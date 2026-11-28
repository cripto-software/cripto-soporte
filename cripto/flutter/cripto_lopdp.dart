// ============================================================
// 📁 RUTA : cripto/flutter/cripto_lopdp.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_lopdp.dart)
// 📌 ARCHIVO: cripto_lopdp.dart
// 📝 RESUMEN: Consentimiento de protección de datos personales
//             (LOPDP Ecuador) de CRIPTO Soporte. Se muestra a
//             pantalla completa la primera vez que se abre la app
//             y cada vez que cambie la versión del aviso. Sin
//             aceptación no se puede usar la app. Guarda la versión
//             y la fecha de aceptación en el propio celular.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  24/11/2026  Versión inicial.
//   v1.1  24/11/2026  Revisión legal (art. 12 LOPDP): servidor en EE. UU.
//                     (transferencia internacional autorizada de forma
//                     expresa), qué pasa si no acepta, sin decisiones
//                     automatizadas, contacto de protección de datos y
//                     plazo de respuesta de 15 días.
//   v1.2  24/11/2026  Acompañantes (solo miran) y aceptación obligatoria
//                     de cada conexión con un toque. El teléfono ya no se
//                     corta en dos líneas.
//   v1.3  27/11/2026  Textos en español e inglés (criptoT, cripto_idioma.dart)
//                     y nombre «CRIPTO Support». Botón «Idioma» antes de aceptar. El texto en español es el que rige.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/platform_model.dart';
import 'cripto_idioma.dart';

// ---------- Datos del responsable (cambiar aquí si algo cambia) ----------
const String kCriptoLopdpVersion = '1'; // Subir a '2' si cambia el texto: se vuelve a pedir.
const String kCriptoClaveLopdp = 'cripto-lopdp-version';
const String kCriptoClaveLopdpFecha = 'cripto-lopdp-fecha';
const String kCriptoResponsable = 'PCG S.A.S. (CRIPTO Software)';
const String kCriptoRuc = '1793191831001';
const String kCriptoDireccion =
    'Víctor Mideros N52-139 y Ramón Borja, Quito, Ecuador';
const String kCriptoCorreo = 'soporte@pc-green.com';
const String kCriptoTelefono = '098 566 6807';
const String kCriptoUrlPrivacidad = 'https://pc-green.com/privacidad';
const int kCriptoDiasGrabacion = 90;
// v1.1 · Transferencia internacional y contacto de protección de datos
const String kCriptoServidorProveedor = 'Contabo Inc.';
const String kCriptoServidorPais = 'Estados Unidos';
const String kCriptoCorreoDatos = 'soporte@pc-green.com';

// ---------- Colores y textos (máximo 3 tamaños) ----------
const Color kCriptoAzul = Color(0xFF0B1029);
const Color kCriptoTexto = Color(0xFF0F172A);
const Color kCriptoFondoSuave = Color(0xFFF1F5F9);
const TextStyle _titulo =
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kCriptoTexto);
const TextStyle _cuerpo = TextStyle(fontSize: 16, color: kCriptoTexto, height: 1.4);
const TextStyle _cuerpoNegrita =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kCriptoTexto);
const TextStyle _pequeno = TextStyle(fontSize: 14, color: kCriptoTexto, height: 1.4);

bool criptoLopdpAceptado() =>
    bind.mainGetLocalOption(key: kCriptoClaveLopdp) == kCriptoLopdpVersion;

/// Puerta de entrada: muestra el consentimiento hasta que se acepte
/// y después muestra la app normal ([child]).
class CriptoPuertaLopdp extends StatefulWidget {
  final Widget child;
  const CriptoPuertaLopdp({Key? key, required this.child}) : super(key: key);

  @override
  State<CriptoPuertaLopdp> createState() => _CriptoPuertaLopdpState();
}

class _CriptoPuertaLopdpState extends State<CriptoPuertaLopdp> {
  late bool _aceptado;

  @override
  void initState() {
    super.initState();
    _aceptado = criptoLopdpAceptado();
    debugPrint('[CRIPTO] Consentimiento LOPDP v$kCriptoLopdpVersion '
        '${_aceptado ? "ya aceptado" : "pendiente"}');
  }

  @override
  Widget build(BuildContext context) {
    if (_aceptado) return widget.child;
    return CriptoConsentimientoPage(
      onAceptar: () => setState(() => _aceptado = true),
    );
  }
}

/// Pantalla completa del aviso de privacidad. Si [soloLectura] es true,
/// solo muestra el texto (para consultarlo después desde la app).
class CriptoConsentimientoPage extends StatefulWidget {
  final VoidCallback? onAceptar;
  final bool soloLectura;
  const CriptoConsentimientoPage(
      {Key? key, this.onAceptar, this.soloLectura = false})
      : super(key: key);

  @override
  State<CriptoConsentimientoPage> createState() =>
      _CriptoConsentimientoPageState();
}

class _CriptoConsentimientoPageState extends State<CriptoConsentimientoPage> {
  bool _marcado = false;

  Future<void> _aceptar() async {
    final fecha = DateTime.now().toIso8601String();
    await bind.mainSetLocalOption(
        key: kCriptoClaveLopdp, value: kCriptoLopdpVersion);
    await bind.mainSetLocalOption(key: kCriptoClaveLopdpFecha, value: fecha);
    debugPrint('[CRIPTO] Consentimiento LOPDP v$kCriptoLopdpVersion aceptado');
    widget.onAceptar?.call();
  }

  Future<void> _noAcepto() async {
    debugPrint('[CRIPTO] Consentimiento LOPDP rechazado');
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(criptoT('Sin consentimiento no hay soporte'), style: _titulo),
        content: Text(
          criptoT('Para darte soporte remoto necesitamos tu autorización. Puedes volver a abrir la app cuando quieras y aceptar.'),
          style: _cuerpo,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(criptoT('Volver'), style: _cuerpoNegrita),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(criptoT('Salir de la app'), style: _cuerpoNegrita),
          ),
        ],
      ),
    );
    if (salir == true) SystemNavigator.pop();
  }

  Future<void> _abrirPolitica() async {
    try {
      await launchUrl(Uri.parse(kCriptoUrlPrivacidad),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[CRIPTO] No se pudo abrir la política de privacidad: $e');
    }
  }

  Widget _seccion(IconData icono, String titulo, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 24, color: kCriptoAzul),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: _cuerpoNegrita),
                const SizedBox(height: 4),
                Text(texto, style: _cuerpo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.soloLectura,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.soloLectura
            ? AppBar(
                backgroundColor: kCriptoAzul,
                foregroundColor: Colors.white,
                title: Text(criptoT('Privacidad')),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              if (!widget.soloLectura)
                Container(
                  width: double.infinity,
                  color: kCriptoAzul,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user, size: 40, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          criptoT('Tu privacidad es importante'),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      // Elegir el idioma antes de aceptar.
                      CriptoBotonIdioma(
                          color: Colors.white, alCambiar: () => setState(() {})),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        criptoT('Antes de usar CRIPTO Support, lee cómo cuidamos tus datos personales, según la Ley Orgánica de Protección de Datos Personales del Ecuador (LOPDP).'),
                        style: _cuerpo,
                      ),
                      const SizedBox(height: 20),
                      _seccion(
                        Icons.business,
                        criptoT('¿Quién es el responsable?'),
                        criptoT('{responsable}, RUC {ruc}. {direccion}. Correo: {correo}.', {'responsable': kCriptoResponsable, 'ruc': kCriptoRuc, 'direccion': kCriptoDireccion, 'correo': kCriptoCorreo}),
                      ),
                      _seccion(
                        Icons.phone_android,
                        criptoT('¿Qué datos usamos?'),
                        criptoT('Solo durante una sesión de soporte que tú aceptes: la imagen de tu pantalla, el control remoto si lo autorizas, los archivos que decidas compartir, el número de identificación (ID) de la app, el modelo de tu celular y la dirección de conexión (IP).'),
                      ),
                      _seccion(
                        Icons.support_agent,
                        criptoT('¿Para qué los usamos?'),
                        criptoT('Únicamente para darte soporte técnico: instalar, configurar o revisar aplicaciones cuando tú lo pides, y para capacitarte.'),
                      ),
                      _seccion(
                        Icons.group_outlined,
                        criptoT('Acompañantes'),
                        criptoT('Tú aceptas cada conexión con un toque. Si quieres, puedes dejar entrar a un acompañante (por ejemplo tu hijo o el dueño de tu empresa): solo puede mirar, nunca controla, y queda registrado quién entró y cuándo.'),
                      ),
                      _seccion(
                        Icons.public,
                        criptoT('Servidor en otro país'),
                        criptoT('El servidor que conecta tu celular con el técnico está contratado con {proveedor} y se encuentra en {pais}. Ahí solo pasan los datos de conexión (ID, IP, fecha y hora); la imagen de tu pantalla viaja cifrada y no se guarda en el servidor. Al aceptar, autorizas esta transferencia internacional.', {'proveedor': kCriptoServidorProveedor, 'pais': criptoT(kCriptoServidorPais)}),
                      ),
                      _seccion(
                        Icons.videocam,
                        criptoT('Grabación de la sesión (opcional)'),
                        criptoT('Antes de cada sesión el técnico te preguntará si deseas grabarla. Si no aceptas, no se graba. Si aceptas, la grabación se guarda {dias} días como respaldo para ti y para nosotros, y luego se elimina.', {'dias': kCriptoDiasGrabacion}),
                      ),
                      _seccion(
                        Icons.block,
                        criptoT('Lo que nunca hacemos'),
                        criptoT('No vendemos ni compartimos tus datos con terceros. No entramos a tu celular sin que aceptes cada conexión. Nunca te pediremos claves del banco, códigos que te lleguen por mensaje ni dinero.'),
                      ),
                      _seccion(
                        Icons.person_off,
                        criptoT('Si no aceptas'),
                        criptoT('Aceptar es voluntario. Si no aceptas, no podrás usar la app ni recibir soporte remoto, pero puedes recibir ayuda por teléfono, correo o de forma presencial. No tomamos decisiones automáticas ni hacemos perfiles con tus datos: siempre te atiende una persona.'),
                      ),
                      _seccion(
                        Icons.gavel,
                        criptoT('Tus derechos'),
                        criptoT('Puedes pedir acceso, rectificación y actualización, eliminación, oposición, portabilidad y suspensión del tratamiento de tus datos escribiendo a {correo} o llamando al {telefono}. Es gratis y te respondemos en máximo 15 días. También puedes acudir a la Superintendencia de Protección de Datos Personales.', {'correo': kCriptoCorreoDatos, 'telefono': kCriptoTelefono.replaceAll(' ', '\u00A0')}),
                      ),
                      _seccion(
                        Icons.undo,
                        criptoT('Retirar tu consentimiento'),
                        criptoT('Puedes retirarlo en cualquier momento escribiéndonos o desinstalando la app.'),
                      ),
                      InkWell(
                        onTap: _abrirPolitica,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.open_in_new,
                                  size: 24, color: kCriptoAzul),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  criptoT('Leer la política de privacidad completa'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: kCriptoAzul,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!widget.soloLectura)
                Container(
                  color: kCriptoFondoSuave,
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 16),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _marcado = !_marcado),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _marcado,
                              activeColor: kCriptoAzul,
                              onChanged: (v) =>
                                  setState(() => _marcado = v ?? false),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  criptoT('He leído este aviso y la política de privacidad, y acepto que PCG S.A.S. trate mis datos personales para darme soporte técnico, incluida su transferencia al servidor en {pais}.', {'pais': criptoT(kCriptoServidorPais)}),
                                  style: _pequeno,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _noAcepto,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: kCriptoAzul,
                                  side: const BorderSide(color: kCriptoAzul),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(criptoT('No acepto'),
                                    style: _cuerpoNegrita),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _marcado ? _aceptar : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kCriptoAzul,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(criptoT('Acepto'),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Abre el aviso de privacidad solo para leerlo (sin botones de aceptar).
void criptoMostrarPrivacidad(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => const CriptoConsentimientoPage(soloLectura: true),
  ));
}

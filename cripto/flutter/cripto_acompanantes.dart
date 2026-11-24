// ============================================================
// 📁 RUTA : cripto/flutter/cripto_acompanantes.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_acompanantes.dart)
// 📌 ARCHIVO: cripto_acompanantes.dart
// 📝 RESUMEN: Acompañantes de las sesiones de soporte y registro de
//             sesiones. Uso Personal (hijo, familiar, amigo) o Empresa
//             (dueño, gerente, contador, bodeguero). Un acompañante SOLO
//             MIRA, nunca controla. En Empresa el acompañamiento puede ser
//             obligatorio y solo se cambia con el PIN del dueño (se guarda
//             su huella SHA-256, nunca el PIN). Todo queda en el registro:
//             fecha, quién, con qué rol y si se aceptó o rechazó.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  24/11/2026  Versión inicial (v1.2 de la app).
// ============================================================

import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/platform_model.dart';
import 'cripto_comun.dart';
import 'cripto_lopdp.dart';

const String _claveConfig = 'cripto-acompanantes';
const String _claveRegistro = 'cripto-registro';

const List<String> kCriptoRolesPersonal = [
  'Hijo o hija',
  'Familiar',
  'Amigo o amiga',
  'Otro',
];
const List<String> kCriptoRolesEmpresa = [
  'Dueño',
  'Gerente',
  'Contador',
  'Bodeguero',
  'Otro',
];

String criptoSoloDigitos(String id) => id.replaceAll(RegExp(r'[^0-9]'), '');

class CriptoAcompanante {
  String nombre;
  String rol;
  String id; // número de CRIPTO Soporte de esa persona (solo dígitos)
  CriptoAcompanante(
      {required this.nombre, required this.rol, required this.id});

  Map<String, dynamic> aJson() => {'nombre': nombre, 'rol': rol, 'id': id};
  static CriptoAcompanante deJson(Map<String, dynamic> j) => CriptoAcompanante(
      nombre: '${j['nombre'] ?? ''}',
      rol: '${j['rol'] ?? ''}',
      id: criptoSoloDigitos('${j['id'] ?? ''}'));
}

class CriptoConfigAcompanantes {
  String modo; // 'personal' | 'empresa'
  bool obligatorio; // solo Empresa
  String pinHuella; // SHA-256 del PIN del dueño; vacío = sin PIN
  List<CriptoAcompanante> personas;

  CriptoConfigAcompanantes({
    this.modo = 'personal',
    this.obligatorio = false,
    this.pinHuella = '',
    List<CriptoAcompanante>? personas,
  }) : personas = personas ?? [];

  bool get esEmpresa => modo == 'empresa';
  bool get exigeAcompanante => esEmpresa && obligatorio && personas.isNotEmpty;

  CriptoAcompanante? buscar(String peerId) {
    final id = criptoSoloDigitos(peerId);
    if (id.isEmpty) return null;
    for (final p in personas) {
      if (p.id == id) return p;
    }
    return null;
  }

  static CriptoConfigAcompanantes cargar() {
    final texto = bind.mainGetLocalOption(key: _claveConfig);
    if (texto.isEmpty) return CriptoConfigAcompanantes();
    try {
      final j = jsonDecode(texto) as Map<String, dynamic>;
      return CriptoConfigAcompanantes(
        modo: j['modo'] == 'empresa' ? 'empresa' : 'personal',
        obligatorio: j['obligatorio'] == true,
        pinHuella: '${j['pin'] ?? ''}',
        personas: ((j['personas'] as List?) ?? [])
            .map((e) =>
                CriptoAcompanante.deJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } catch (e) {
      debugPrint('[CRIPTO] Configuración de acompañantes ilegible: $e');
      return CriptoConfigAcompanantes();
    }
  }

  Future<void> guardar() async {
    await bind.mainSetLocalOption(
        key: _claveConfig,
        value: jsonEncode({
          'modo': modo,
          'obligatorio': obligatorio,
          'pin': pinHuella,
          'personas': personas.map((p) => p.aJson()).toList(),
        }));
    debugPrint('[CRIPTO] Acompañantes guardados: modo=$modo, '
        'personas=${personas.length}, obligatorio=$obligatorio');
  }
}

// ------------------------------------------------------------
// Registro de sesiones (respaldo legal; se guarda en el celular)
// ------------------------------------------------------------
class CriptoRegistro {
  static List<Map<String, dynamic>> leer() {
    final texto = bind.mainGetLocalOption(key: _claveRegistro);
    if (texto.isEmpty) return [];
    try {
      return (jsonDecode(texto) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> agregar({
    required String evento,
    String id = '',
    String nombre = '',
    String rol = '',
  }) async {
    final lista = leer();
    lista.add({
      'fecha': DateTime.now().toIso8601String(),
      'evento': evento,
      'id': criptoSoloDigitos(id),
      'nombre': nombre,
      'rol': rol,
    });
    await bind.mainSetLocalOption(key: _claveRegistro, value: jsonEncode(lista));
    debugPrint('[CRIPTO] Registro: $evento · rol=$rol');
  }
}

// ------------------------------------------------------------
// Pantalla: Persona de confianza / Acompañantes
// ------------------------------------------------------------
class CriptoAcompanantesPage extends StatefulWidget {
  const CriptoAcompanantesPage({Key? key}) : super(key: key);

  @override
  State<CriptoAcompanantesPage> createState() => _CriptoAcompanantesPageState();
}

class _CriptoAcompanantesPageState extends State<CriptoAcompanantesPage> {
  late CriptoConfigAcompanantes _cfg;
  final _nombre = TextEditingController();
  final _id = TextEditingController();
  String _rol = kCriptoRolesPersonal.first;

  @override
  void initState() {
    super.initState();
    _cfg = CriptoConfigAcompanantes.cargar();
    _rol = _roles.first;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _id.dispose();
    super.dispose();
  }

  List<String> get _roles =>
      _cfg.esEmpresa ? kCriptoRolesEmpresa : kCriptoRolesPersonal;

  /// Si hay PIN del dueño, lo pide antes de cualquier cambio.
  Future<bool> _verificarPin() async {
    if (_cfg.pinHuella.isEmpty) return true;
    final pin = await _pedirPin('PIN del dueño',
        'Este celular tiene el acompañamiento protegido. Escribe el PIN del dueño.');
    if (pin == null) return false;
    final ok = criptoSha256(pin) == _cfg.pinHuella;
    if (!ok) {
      await CriptoRegistro.agregar(evento: 'PIN incorrecto al cambiar acompañantes');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN incorrecto. No se hizo ningún cambio.')));
      }
    }
    return ok;
  }

  Future<String?> _pedirPin(String titulo, String texto) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(titulo, style: kCriTitulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texto, style: kCriCuerpo),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              style: kCriCuerpo,
              decoration: const InputDecoration(
                  labelText: 'PIN (4 a 8 números)',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('Cancelar', style: kCriCuerpoNegrita)),
          TextButton(
              onPressed: () {
                final v = ctrl.text.trim();
                if (RegExp(r'^\d{4,8}$').hasMatch(v)) Navigator.of(c).pop(v);
              },
              child: const Text('Aceptar', style: kCriCuerpoNegrita)),
        ],
      ),
    );
  }

  Future<void> _cambiarModo(String modo) async {
    if (modo == _cfg.modo) return;
    if (!await _verificarPin()) return;
    setState(() {
      _cfg.modo = modo;
      if (modo == 'personal') _cfg.obligatorio = false;
      _rol = _roles.first;
    });
    await _cfg.guardar();
  }

  Future<void> _agregar() async {
    final nombre = _nombre.text.trim();
    final id = criptoSoloDigitos(_id.text);
    if (nombre.isEmpty || id.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Escribe el nombre y el número de soporte completo.')));
      return;
    }
    if (!await _verificarPin()) return;
    setState(() {
      _cfg.personas.removeWhere((p) => p.id == id);
      _cfg.personas.add(CriptoAcompanante(nombre: nombre, rol: _rol, id: id));
      _nombre.clear();
      _id.clear();
    });
    await _cfg.guardar();
    await CriptoRegistro.agregar(
        evento: 'Acompañante agregado', id: id, nombre: nombre, rol: _rol);
  }

  Future<void> _quitar(CriptoAcompanante p) async {
    if (!await _verificarPin()) return;
    setState(() => _cfg.personas.remove(p));
    await _cfg.guardar();
    await CriptoRegistro.agregar(
        evento: 'Acompañante quitado', id: p.id, nombre: p.nombre, rol: p.rol);
  }

  Future<void> _cambiarObligatorio(bool valor) async {
    if (valor) {
      if (_cfg.personas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Primero agrega al dueño o a quien deba acompañar.')));
        return;
      }
      if (_cfg.pinHuella.isEmpty) {
        final pin = await _pedirPin('Crear PIN del dueño',
            'Solo el dueño debe conocer este PIN. Sin él nadie podrá quitar el acompañamiento obligatorio.');
        if (pin == null) return;
        _cfg.pinHuella = criptoSha256(pin);
      } else if (!await _verificarPin()) {
        return;
      }
    } else if (!await _verificarPin()) {
      return;
    }
    setState(() => _cfg.obligatorio = valor);
    await _cfg.guardar();
    await CriptoRegistro.agregar(
        evento: valor
            ? 'Acompañamiento obligatorio activado'
            : 'Acompañamiento obligatorio desactivado');
  }

  Widget _selectorModo() {
    Widget opcion(String modo, String texto) {
      final activo = _cfg.modo == modo;
      return Expanded(
        child: SizedBox(
          height: 52,
          child: TextButton(
            onPressed: () => _cambiarModo(modo),
            style: TextButton.styleFrom(
              backgroundColor: activo ? kCriptoAzul : Colors.white,
              foregroundColor: activo ? Colors.white : kCriptoAzul,
              shape: const RoundedRectangleBorder(),
            ),
            child: Text(texto,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: kCriptoAzul, width: 2),
          borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        opcion('personal', 'Personal'),
        opcion('empresa', 'Empresa'),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empresa = _cfg.esEmpresa;
    return Scaffold(
      backgroundColor: kCriptoFondo,
      body: Column(
        children: [
          CriptoEncabezado(subtitulo: 'Acompañantes', acciones: [
            IconButton(
              tooltip: 'Volver',
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('¿Para qué usas CRIPTO Soporte?',
                    style: kCriCuerpoNegrita),
                const SizedBox(height: 8),
                _selectorModo(),
                const SizedBox(height: 12),
                Text(
                  empresa
                      ? 'Quién de la empresa acompaña el soporte de este celular. Solo mira, nunca toca.'
                      : 'Alguien de confianza que pueda mirar tus sesiones. Solo mira, nunca toca.',
                  style: kCriCuerpo,
                ),
                const SizedBox(height: 16),
                for (final p in _cfg.personas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: criptoTarjeta(Row(
                      children: [
                        const Icon(Icons.visibility,
                            size: 24, color: kCriptoAzul),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p.nombre} · ${p.rol}',
                                  style: kCriCuerpoNegrita),
                              Text('Número ${p.id}', style: kCriPequeno),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Quitar',
                          icon: const Icon(Icons.delete_outline,
                              size: 24, color: kCriptoRojo),
                          onPressed: () => _quitar(p),
                        ),
                      ],
                    )),
                  ),
                criptoTarjeta(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agregar persona', style: kCriCuerpoNegrita),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nombre,
                      style: kCriCuerpo,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Nombre', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Text(empresa ? 'Cargo en la empresa' : '¿Quién es para ti?',
                        style: kCriPequeno),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final r in _roles)
                          ChoiceChip(
                            label: Text(r,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: r == _rol
                                        ? Colors.white
                                        : kCriptoAzul)),
                            selected: r == _rol,
                            selectedColor: kCriptoAzul,
                            backgroundColor: Colors.white,
                            showCheckmark: false,
                            side: const BorderSide(color: kCriptoAzul),
                            onSelected: (_) => setState(() => _rol = r),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _id,
                      style: kCriCuerpo,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Su número de CRIPTO Soporte',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    criptoBotonPrincipal('Agregar', _agregar,
                        icono: Icons.person_add_alt_1),
                  ],
                )),
                if (empresa) ...[
                  const SizedBox(height: 16),
                  criptoTarjeta(
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _cfg.obligatorio,
                      activeColor: kCriptoAzulMarca,
                      onChanged: _cambiarObligatorio,
                      title: const Text('Obligatorio en cada soporte',
                          style: kCriCuerpoNegrita),
                      subtitle: const Text(
                          'El técnico no puede entrar hasta que se conecte un acompañante de la lista. Se cambia solo con el PIN del dueño.',
                          style: kCriPequeno),
                    ),
                    relleno: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Pantalla: Historial de sesiones (todo el registro, sin cortes)
// ------------------------------------------------------------
class CriptoRegistroPage extends StatelessWidget {
  const CriptoRegistroPage({Key? key}) : super(key: key);

  String _fecha(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(d.day)}/${dos(d.month)}/${d.year} ${dos(d.hour)}:${dos(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final lista = CriptoRegistro.leer().reversed.toList();
    return Scaffold(
      backgroundColor: kCriptoFondo,
      body: Column(
        children: [
          CriptoEncabezado(subtitulo: 'Historial de sesiones', acciones: [
            IconButton(
              tooltip: 'Volver',
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text('Todavía no hay sesiones registradas.',
                        style: kCriCuerpo))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: kCriptoBorde),
                    itemBuilder: (_, i) {
                      final r = lista[i];
                      final quien = [
                        if ('${r['nombre']}'.isNotEmpty) '${r['nombre']}',
                        if ('${r['rol']}'.isNotEmpty) '${r['rol']}',
                        if ('${r['id']}'.isNotEmpty) 'N.º ${r['id']}',
                      ].join(' · ');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${r['evento']}', style: kCriCuerpoNegrita),
                            if (quien.isNotEmpty)
                              Text(quien, style: kCriPequeno),
                            Text(_fecha('${r['fecha']}'), style: kCriPequeno),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

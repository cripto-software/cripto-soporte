// ============================================================
// 📁 RUTA : cripto/flutter/cripto_idioma.dart
//          (al compilar se copia a flutter/lib/cripto/cripto_idioma.dart)
// 📌 ARCHIVO: cripto_idioma.dart
// 📝 RESUMEN: Idiomas de CRIPTO Support (Windows y Android), hecho para
//             crecer. Los textos propios de CRIPTO se escriben en español
//             dentro de criptoT('...') y cada idioma extra es una lista
//             de traducciones en su propio archivo (cripto_textos_en.dart
//             para inglés). Para agregar un idioma nuevo (por ejemplo
//             portugués): 1) crear cripto_textos_pt.dart con su lista,
//             2) sumarlo en kCriptoIdiomas. Las pantallas no se tocan.
//             El idioma sale del equipo (automático) o del botón
//             «Idioma» de la pantalla principal, y es el mismo ajuste que
//             usa el motor, así todo el programa cambia junto.
//             Si a un texto le falta traducción se muestra en español.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  27/11/2026  Versión inicial: español (base) e inglés.
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common.dart';
import '../consts.dart';
import '../models/platform_model.dart';
import 'cripto_textos_en.dart';

/// Un idioma disponible en CRIPTO Support.
class CriptoIdioma {
  /// Código que también entiende el motor (es, en, pt…).
  final String codigo;

  /// Nombre del idioma escrito en ese mismo idioma.
  final String nombre;

  /// Traducciones: texto en español → texto en este idioma.
  /// Vacío para el español, que es la base.
  final Map<String, String> textos;

  const CriptoIdioma(this.codigo, this.nombre, this.textos);
}

/// Idioma base: los textos se escriben en español.
const String kCriptoIdiomaBase = 'es';

/// Idiomas del botón «Idioma». Para sumar uno nuevo, agréguelo aquí.
const List<CriptoIdioma> kCriptoIdiomas = [
  CriptoIdioma('es', 'Español', {}),
  CriptoIdioma('en', 'English', kCriptoTextosEn),
];

CriptoIdioma? _buscarIdioma(String codigo) {
  final c = codigo.toLowerCase();
  for (final i in kCriptoIdiomas) {
    if (c == i.codigo || c.startsWith('${i.codigo}-') || c.startsWith('${i.codigo}_')) {
      return i;
    }
  }
  return null;
}

/// Idioma del sistema operativo (es_EC → es). Si no está entre los
/// disponibles se usa inglés, que entiende más gente fuera de Ecuador.
String _idiomaDelEquipo() {
  try {
    final i = _buscarIdioma(Platform.localeName);
    if (i != null) return i.codigo;
  } catch (_) {}
  return 'en';
}

/// Valor guardado en la configuración: '' = automático.
String criptoIdiomaGuardado() {
  final i = _buscarIdioma(bind.mainGetLocalOption(key: kCommConfKeyLang));
  return i?.codigo ?? '';
}

/// Código del idioma que se está mostrando ahora.
String criptoIdiomaActual() {
  final guardado = criptoIdiomaGuardado();
  return guardado.isNotEmpty ? guardado : _idiomaDelEquipo();
}

/// true si la pantalla está en inglés (para casos especiales).
bool criptoEnIngles() => criptoIdiomaActual() == 'en';

/// Traduce un texto propio de CRIPTO escrito en español.
/// Los datos variables van entre llaves: criptoT('Número {id}', {'id': x}).
String criptoT(String es, [Map<String, Object?> datos = const {}]) {
  var texto = es;
  final actual = criptoIdiomaActual();
  if (actual != kCriptoIdiomaBase) {
    final traducido = _buscarIdioma(actual)?.textos[es];
    if (traducido != null && traducido.isNotEmpty) {
      texto = traducido;
    } else {
      debugPrint('[CRIPTO] Idioma $actual: falta traducción de «$es»');
    }
  }
  datos.forEach((clave, valor) {
    texto = texto.replaceAll('{$clave}', '${valor ?? ''}');
  });
  return texto;
}

/// Cambia el idioma de todo el programa. '' = automático (el del equipo).
Future<void> criptoCambiarIdioma(String codigo) async {
  final valor = codigo.isEmpty ? defaultOptionLang : codigo;
  await bind.mainSetLocalOption(key: kCommConfKeyLang, value: valor);
  debugPrint('[CRIPTO] Idioma elegido: ${codigo.isEmpty ? 'automático' : codigo}');
  if (isDesktop) {
    await reloadAllWindows();
    bind.mainChangeLanguage(lang: valor);
  } else {
    Get.forceAppUpdate();
  }
}

/// Botón «Idioma» para la pantalla principal (Windows y celular).
class CriptoBotonIdioma extends StatefulWidget {
  /// Color del texto y del ícono (blanco sobre encabezados azules).
  final Color? color;

  /// Se llama después de cambiar el idioma (para redibujar la pantalla).
  final VoidCallback? alCambiar;

  const CriptoBotonIdioma({Key? key, this.color, this.alCambiar}) : super(key: key);

  @override
  State<CriptoBotonIdioma> createState() => _CriptoBotonIdiomaState();
}

class _CriptoBotonIdiomaState extends State<CriptoBotonIdioma> {
  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final color = widget.color ?? (oscuro ? Colors.white : const Color(0xFF0F172A));
    final guardado = criptoIdiomaGuardado();
    final actual = _buscarIdioma(criptoIdiomaActual());
    return PopupMenuButton<String>(
      tooltip: criptoT('Idioma'),
      initialValue: guardado,
      onSelected: (codigo) async {
        await criptoCambiarIdioma(codigo);
        if (mounted) setState(() {});
        widget.alCambiar?.call();
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: '',
          height: 40,
          child: _opcion(criptoT('Automático (idioma del equipo)'), guardado.isEmpty),
        ),
        for (final i in kCriptoIdiomas)
          PopupMenuItem<String>(
            value: i.codigo,
            height: 40,
            child: _opcion(i.nombre, guardado == i.codigo),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.language, size: 20, color: color),
          const SizedBox(width: 6),
          Text(actual?.nombre ?? 'Idioma',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          Icon(Icons.arrow_drop_down, size: 20, color: color),
        ]),
      ),
    );
  }

  Widget _opcion(String texto, bool elegido) {
    return Row(children: [
      SizedBox(
        width: 24,
        child: elegido
            ? const Icon(Icons.check, size: 18, color: Color(0xFF2563EB))
            : null,
      ),
      const SizedBox(width: 8),
      Text(texto, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
    ]);
  }
}

# ============================================================
# 📁 RUTA   : cripto/aplicar_marca.py
# 📌 ARCHIVO: aplicar_marca.py
# 📝 RESUMEN: Aplica la marca CRIPTO Soporte al código antes de
#             compilar la app de Android: servidor y llave pública
#             (leídos de los Secrets de GitHub), nombre de la app,
#             identificador com.criptosoftware.soporte e íconos.
#             Además inserta las pantallas propias de CRIPTO
#             (consentimiento LOPDP, aviso de seguridad y aviso de
#             Accesibilidad) que están en cripto/flutter/.
#             v1.2: pantalla «Pedir ayuda», aceptación de cada conexión
#             con roles Técnico/Acompañante, acompañantes con PIN y
#             registro de sesiones, logo oficial dentro de la app.
#             Si algo no coincide, detiene la compilación con un
#             mensaje claro. Nunca imprime el servidor ni la llave.
# 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
# ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
#    (Este archivo forma parte de un trabajo derivado de RustDesk,
#     distribuido bajo la licencia AGPL-3.0.)
# ------------------------------------------------------------
# Historial
#   v1.0  23/11/2026  Versión inicial.
#   v1.1  24/11/2026  Pantallas CRIPTO: consentimiento LOPDP al abrir la
#                     app, aviso de seguridad propio en lugar del aviso de
#                     estafas de RustDesk y divulgación destacada del
#                     permiso de Accesibilidad (requisito de Google Play).
#   v1.2  24/11/2026  App v1.2: inicio «Pedir ayuda» (cripto_inicio.dart),
#                     ventana de solicitud con roles Técnico/Acompañante
#                     (cripto_solicitud.dart), acompañantes Personal/Empresa
#                     con PIN y registro (cripto_acompanantes.dart), piezas
#                     comunes y logo (cripto_comun.dart). Se copia el logo a
#                     flutter/assets/cripto_logo.png. Se quitan las preguntas
#                     de carpetas y el aviso de inicio de RustDesk (el aviso
#                     CRIPTO va antes) y la descripción de Accesibilidad
#                     queda en español.
#   v1.3  24/11/2026  App v1.3: minSdk 24 (Android 7.0 o superior), exigido
#                     por la protección automática de Google Play. Marca
#                     CRIPTO Soporte también en la notificación del servicio,
#                     en el canal de notificaciones, en el menú del botón
#                     flotante y en el aviso de arranque (antes decían
#                     «RustDesk»). WhatsApp directo al chat de soporte
#                     (cambio en cripto_inicio.dart).
#   v1.4  24/11/2026  Modo Windows (python cripto/aplicar_marca.py --windows)
#                     para CRIPTO Soporte de escritorio (técnico): mismo
#                     servidor y llave, nombre en el ejecutable (Runner.rc),
#                     íconos .ico con el logo transparente, logo con nombre
#                     dentro de la app (claro y oscuro), calidad máxima por
#                     defecto (mejor imagen, 60 fps, color 4:4:4, imagen
#                     ajustada a la ventana) y ajustes de servidor ocultos.
#                     Sin argumentos sigue haciendo exactamente lo de Android.
# ============================================================

import os
import re
import shutil
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent

NOMBRE_APP = "CRIPTO Soporte"
NOMBRE_SERVICIO = "CRIPTO Soporte Control"
APP_ID_ORIGINAL = "com.carriez.flutter_hbb"
APP_ID_CRIPTO = "com.criptosoftware.soporte"
COLOR_FONDO_ICONO = "#0B1029"
MIN_SDK_CRIPTO = 24  # v1.3 — requisito de la protección automática de Google Play

# Tamaños oficiales de Android: (carpeta, ícono clásico, primer plano adaptable)
TAMANOS = [
    ("mipmap-mdpi", 48, 108),
    ("mipmap-hdpi", 72, 162),
    ("mipmap-xhdpi", 96, 216),
    ("mipmap-xxhdpi", 144, 324),
    ("mipmap-xxxhdpi", 192, 432),
]


def error(msg: str) -> None:
    # Formato de anotación de GitHub Actions: se ve en rojo en el resumen.
    print(f"::error::{msg}")
    sys.exit(1)


def ok(msg: str) -> None:
    print(f"[CRIPTO] OK  {msg}")


def reemplazar_una_vez(ruta: Path, patron: str, nuevo: str, descripcion: str) -> None:
    if not ruta.exists():
        error(f"No existe {ruta.relative_to(RAIZ)} ({descripcion}). ¿Cambió la estructura de RustDesk?")
    texto = ruta.read_text(encoding="utf-8")
    nuevo_texto, cantidad = re.subn(patron, lambda _m: nuevo, texto)
    if cantidad != 1:
        error(
            f"{descripcion}: se esperaba 1 coincidencia en {ruta.relative_to(RAIZ)} "
            f"y hubo {cantidad}. Revisar tras el último «Sync fork»."
        )
    ruta.write_text(nuevo_texto, encoding="utf-8")
    ok(descripcion)


def leer_secretos() -> tuple[str, str]:
    servidor = os.environ.get("RENDEZVOUS_SERVER", "").strip()
    llave = os.environ.get("RS_PUB_KEY", "").strip()
    if not servidor:
        error("Falta el secret RENDEZVOUS_SERVER (Settings → Secrets and variables → Actions).")
    if not llave:
        error("Falta el secret RS_PUB_KEY (Settings → Secrets and variables → Actions).")
    if not re.fullmatch(r"[A-Za-z0-9.-]+(:\d{2,5})?", servidor):
        error("RENDEZVOUS_SERVER no tiene formato válido: debe ser solo el dominio, sin http:// ni espacios.")
    if not re.fullmatch(r"[A-Za-z0-9+/]{43}=", llave):
        error(
            "RS_PUB_KEY no tiene formato válido: debe ser la línea de 44 caracteres del archivo "
            "id_ed25519.pub (nunca la llave privada)."
        )
    ok("Secrets RENDEZVOUS_SERVER y RS_PUB_KEY presentes y con formato válido")
    return servidor, llave


def aplicar_servidor(servidor: str, llave: str) -> None:
    config = RAIZ / "libs" / "hbb_common" / "src" / "config.rs"
    reemplazar_una_vez(
        config,
        r'pub const RENDEZVOUS_SERVERS: &\[&str\] = &\[[^\]]*\];',
        f'pub const RENDEZVOUS_SERVERS: &[&str] = &["{servidor}"];',
        "Servidor propio aplicado",
    )
    reemplazar_una_vez(
        config,
        r'pub const RS_PUB_KEY: &str = "[^"]*";',
        f'pub const RS_PUB_KEY: &str = "{llave}";',
        "Llave pública propia aplicada",
    )
    reemplazar_una_vez(
        config,
        r'APP_NAME: RwLock<String> = RwLock::new\("RustDesk"\.to_owned\(\)\);',
        f'APP_NAME: RwLock<String> = RwLock::new("{NOMBRE_APP}".to_owned());',
        "Nombre interno de la app",
    )


def aplicar_android() -> None:
    android = RAIZ / "flutter" / "android" / "app"
    reemplazar_una_vez(
        android / "build.gradle",
        rf'applicationId "{re.escape(APP_ID_ORIGINAL)}"',
        f'applicationId "{APP_ID_CRIPTO}"',
        f"Identificador de la app ({APP_ID_CRIPTO})",
    )
    # v1.3 — Android 7.0 o superior (la protección automática de Play exige 24).
    reemplazar_una_vez(
        android / "build.gradle",
        r"minSdkVersion \d+",
        f"minSdkVersion {MIN_SDK_CRIPTO}",
        f"Versión mínima de Android (minSdk {MIN_SDK_CRIPTO})",
    )
    manifiesto =android / "src" / "main" / "AndroidManifest.xml"
    reemplazar_una_vez(manifiesto, r'android:label="RustDesk"', f'android:label="{NOMBRE_APP}"',
                       "Nombre visible de la app")
    reemplazar_una_vez(manifiesto, r'android:label="RustDesk Input"', f'android:label="{NOMBRE_SERVICIO}"',
                       "Nombre del servicio de accesibilidad")

    textos = android / "src" / "main" / "res" / "values" / "strings.xml"
    reemplazar_una_vez(textos, r'<string name="app_name">RustDesk</string>',
                       f'<string name="app_name">{NOMBRE_APP}</string>', "Texto app_name")
    contenido = textos.read_text(encoding="utf-8").replace("RustDesk", NOMBRE_APP)
    textos.write_text(contenido, encoding="utf-8")
    ok("Textos del sistema con el nombre CRIPTO Soporte")

    reemplazar_una_vez(
        android / "src" / "main" / "res" / "values" / "ic_launcher_background.xml",
        r'<color name="ic_launcher_background">#[0-9A-Fa-f]{6,8}</color>',
        f'<color name="ic_launcher_background">{COLOR_FONDO_ICONO}</color>',
        "Color de fondo del ícono",
    )

    # v1.3 — Marca CRIPTO en los textos fijos del código Kotlin.
    kotlin = android / "src" / "main" / "kotlin" / "com" / "carriez" / "flutter_hbb"
    servicio = kotlin / "MainService.kt"
    reemplazar_una_vez(
        servicio,
        r'const val DEFAULT_NOTIFY_TITLE = "RustDesk"',
        f'const val DEFAULT_NOTIFY_TITLE = "{NOMBRE_APP}"',
        "Título de la notificación del servicio",
    )
    reemplazar_una_vez(
        servicio,
        r'val channelName = "RustDesk Service"',
        f'val channelName = "{NOMBRE_APP}"',
        "Nombre del canal de notificaciones",
    )
    reemplazar_una_vez(
        servicio,
        r'description = "RustDesk Service Channel"',
        'description = "Avisos de las sesiones de soporte de CRIPTO Software"',
        "Descripción del canal de notificaciones",
    )
    reemplazar_una_vez(
        kotlin / "FloatingWindowService.kt",
        r'translate\("Show RustDesk"\)',
        f'"Abrir {NOMBRE_APP}"',
        "Menú del botón flotante",
    )
    reemplazar_una_vez(
        kotlin / "BootReceiver.kt",
        r'"RustDesk is Open"',
        f'"{NOMBRE_APP} está activo"',
        "Aviso de arranque del celular",
    )


def aplicar_iconos() -> None:
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        error("Falta la librería Pillow (pip install pillow).")

    marca = RAIZ / "cripto" / "marca"
    origen_primer_plano = marca / "ic_launcher_foreground_432.png"
    origen_icono = marca / "icono_1024.png"
    for archivo in (origen_primer_plano, origen_icono):
        if not archivo.exists():
            error(f"Falta el archivo de marca {archivo.relative_to(RAIZ)}.")

    primer_plano = Image.open(origen_primer_plano).convert("RGBA")
    icono = Image.open(origen_icono).convert("RGBA")
    res = RAIZ / "flutter" / "android" / "app" / "src" / "main" / "res"

    for carpeta, lado_icono, lado_primer_plano in TAMANOS:
        destino = res / carpeta
        if not destino.is_dir():
            error(f"No existe la carpeta de íconos {destino.relative_to(RAIZ)}.")
        primer_plano.resize((lado_primer_plano, lado_primer_plano), Image.LANCZOS).save(
            destino / "ic_launcher_foreground.png", optimize=True)
        clasico = icono.resize((lado_icono, lado_icono), Image.LANCZOS)
        clasico.save(destino / "ic_launcher.png", optimize=True)
        mascara = Image.new("L", (lado_icono, lado_icono), 0)
        ImageDraw.Draw(mascara).ellipse((0, 0, lado_icono - 1, lado_icono - 1), fill=255)
        redondo = Image.new("RGBA", (lado_icono, lado_icono), (0, 0, 0, 0))
        redondo.paste(clasico, (0, 0), mascara)
        redondo.save(destino / "ic_launcher_round.png", optimize=True)
    ok("Íconos CRIPTO generados en las 5 densidades de Android")


def aplicar_flutter() -> None:
    """Copia las pantallas de cripto/flutter/ y las conecta con la app."""
    origen = RAIZ / "cripto" / "flutter"
    lib = RAIZ / "flutter" / "lib"
    destino = lib / "cripto"
    archivos = (
        "cripto_lopdp.dart",
        "cripto_avisos.dart",
        "cripto_comun.dart",  # v1.2
        "cripto_acompanantes.dart",  # v1.2
        "cripto_solicitud.dart",  # v1.2
        "cripto_inicio.dart",  # v1.2
    )
    destino.mkdir(parents=True, exist_ok=True)
    for nombre in archivos:
        archivo = origen / nombre
        if not archivo.exists():
            error(f"Falta el archivo {archivo.relative_to(RAIZ)}.")
        shutil.copyfile(archivo, destino / nombre)
    ok("Pantallas CRIPTO copiadas a flutter/lib/cripto/")

    main_dart = lib / "main.dart"
    reemplazar_una_vez(
        main_dart,
        r"(?m)^import 'mobile/pages/home_page\.dart';$",
        "import 'mobile/pages/home_page.dart';\nimport 'cripto/cripto_lopdp.dart';\n"
        "import 'cripto/cripto_inicio.dart';",
        "Importación del consentimiento LOPDP",
    )
    reemplazar_una_vez(
        main_dart,
        r": HomePage\(\),",
        ": const CriptoPuertaLopdp(child: CriptoInicioPage()),",
        "Consentimiento LOPDP y pantalla «Pedir ayuda» como inicio",
    )

    servidor = lib / "mobile" / "pages" / "server_page.dart"
    reemplazar_una_vez(
        servidor,
        r"(?m)^import 'home_page\.dart';$",
        "import 'home_page.dart';\nimport '../../cripto/cripto_avisos.dart';",
        "Importación de los avisos CRIPTO (pantalla compartir)",
    )
    reemplazar_una_vez(
        servidor,
        r"return ScamWarningDialog\(serverModel: serverModel\);",
        "return CriptoAvisoSeguridad(serverModel: serverModel);",
        "Aviso de seguridad CRIPTO en lugar del aviso de estafas",
    )

    modelo = lib / "models" / "server_model.dart"
    reemplazar_una_vez(
        modelo,
        r"(?m)^import 'model\.dart';$",
        "import 'model.dart';\nimport '../cripto/cripto_avisos.dart';\n"
        "import '../cripto/cripto_solicitud.dart';",
        "Importación de los avisos CRIPTO (modelo del servidor)",
    )
    reemplazar_una_vez(
        modelo,
        r"(?m)^showInputWarnAlert\(FFI ffi\) \{",
        "showInputWarnAlert(FFI ffi) => criptoAvisoAccesibilidad(ffi);\n\n"
        "showInputWarnAlertRustDesk(FFI ffi) {",
        "Divulgación destacada del permiso de Accesibilidad",
    )
    # v1.2 — Solicitud de conexión CRIPTO (roles Técnico / Acompañante).
    reemplazar_una_vez(
        modelo,
        r"(?m)^  void showLoginDialog\(Client client\) \{",
        "  void showLoginDialog(Client client) => criptoSolicitudConexion(this, client);\n\n"
        "  void showLoginDialogRustDesk(Client client) {",
        "Ventana de solicitud CRIPTO con roles",
    )
    # v1.2 — Sin preguntas de carpetas: siempre la carpeta propia de la app.
    reemplazar_una_vez(
        modelo,
        r"await AndroidDocuments\.requireLogFolder\(\);\s*await showAndroidFileTransferSetup\(gFFI\);",
        "await criptoPrepararCarpetas(gFFI);",
        "Carpeta propia de la app sin preguntar",
    )
    # v1.2 — Sin el aviso de inicio de RustDesk: el aviso CRIPTO va antes.
    reemplazar_una_vez(
        modelo,
        r"(await checkFloatingWindowPermission\(\);\s*\}\n)",
        "await checkFloatingWindowPermission();\n      }\n"
        "      // CRIPTO: el aviso propio ya se mostró antes de iniciar.\n"
        "      startService();\n      return;\n",
        "Inicio del servicio sin el aviso de RustDesk",
    )

    # v1.2 — Descripción del permiso de Accesibilidad en español.
    textos = RAIZ / "flutter" / "android" / "app" / "src" / "main" / "res" / "values" / "strings.xml"
    reemplazar_una_vez(
        textos,
        r'<string name="accessibility_service_description">[^<]*</string>',
        '<string name="accessibility_service_description">Permite que el técnico de '
        'CRIPTO Software toque y escriba en tu pantalla solo durante una sesión de '
        'soporte que tú aceptaste. No lee mensajes ni contraseñas.</string>',
        "Descripción de Accesibilidad en español",
    )

    # v1.2 — Logo oficial dentro de la app (la marca es la publicidad).
    try:
        from PIL import Image
    except ImportError:
        error("Falta la librería Pillow (pip install pillow).")
    origen_logo = RAIZ / "cripto" / "marca" / "icono_1024.png"
    if not origen_logo.exists():
        error(f"Falta el archivo de marca {origen_logo.relative_to(RAIZ)}.")
    logo = Image.open(origen_logo).convert("RGBA")
    lado = logo.size[0]
    margen = int(lado * 0.256)
    logo.crop((margen, margen, lado - margen, lado - margen)).resize(
        (512, 512), Image.LANCZOS).save(RAIZ / "flutter" / "assets" / "cripto_logo.png", optimize=True)
    ok("Logo CRIPTO copiado a flutter/assets/cripto_logo.png")


# ------------------------------------------------------------
# v1.4 — Windows (CRIPTO Soporte de escritorio para el técnico)
# ------------------------------------------------------------
EMPRESA = "PCG S.A.S."
COLOR_FONDO_RGB = (11, 16, 41)  # mismo azul del fondo de icono_1024.png

# Calidad por defecto: lo mejor desde el primer uso (el técnico puede cambiarlo).
AJUSTES_IMAGEN_CRIPTO = {
    "image_quality": "best",     # Mejor calidad de imagen
    "custom-fps": "60",          # 60 cuadros por segundo
    "i444": "Y",                 # Color real 4:4:4 (texto nítido)
    "view_style": "adaptive",    # Ajustar la pantalla remota a la ventana
    "codec-preference": "auto",  # El mejor códec que soporten los dos equipos
}
# Ajustes fijos de fábrica: el servidor propio no se puede cambiar desde la app.
AJUSTES_FIJOS_CRIPTO = {
    "hide-server-settings": "Y",
    "hide-proxy-settings": "Y",
    "hide-websocket-settings": "Y",
}


def _mapa_rust(valores: dict) -> str:
    pares = ", ".join(f'("{k}".to_owned(), "{v}".to_owned())' for k, v in valores.items())
    return f"RwLock::new(HashMap::from([{pares}]))"


def _logo_transparente():
    """Quita el fondo azul de icono_1024.png y deja solo el logo (RGBA, recortado)."""
    try:
        from PIL import Image
        import numpy as np
    except ImportError:
        error("Faltan las librerías Pillow y numpy (pip install pillow numpy).")
    origen = RAIZ / "cripto" / "marca" / "icono_1024.png"
    if not origen.exists():
        error(f"Falta el archivo de marca {origen.relative_to(RAIZ)}.")
    rgb = np.array(Image.open(origen).convert("RGB")).astype(float)
    fondo = np.array(COLOR_FONDO_RGB, dtype=float)
    distancia = np.sqrt(((rgb - fondo) ** 2).sum(axis=2))
    alfa = np.clip((distancia - 6) * 4, 0, 255)
    a = alfa[..., None] / 255.0
    color = np.where(a > 0.01, (rgb - fondo * (1 - a)) / np.maximum(a, 0.01), 0)
    imagen = Image.fromarray(np.dstack([np.clip(color, 0, 255), alfa]).astype("uint8"), "RGBA")
    caja = imagen.getbbox()
    if not caja:
        error("No se pudo separar el logo del fondo en icono_1024.png.")
    imagen = imagen.crop(caja)
    lado = max(imagen.size)
    margen = int(lado * 0.04)
    cuadro = Image.new("RGBA", (lado + 2 * margen, lado + 2 * margen), (0, 0, 0, 0))
    cuadro.paste(imagen, ((lado - imagen.size[0]) // 2 + margen, (lado - imagen.size[1]) // 2 + margen))
    return cuadro


def _fuente(tamano: int, negrita: bool):
    from PIL import ImageFont
    candidatas = (
        ["C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf",
         "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"]
        if negrita else
        ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
         "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]
    )
    for ruta in candidatas:
        if Path(ruta).exists():
            return ImageFont.truetype(ruta, tamano)
    return ImageFont.load_default()


def _logo_con_nombre(logo, color_texto, color_soporte):
    """Logo + «CRIPTO Soporte» en 600×120 (se muestra a 300×60 en la app)."""
    from PIL import Image, ImageDraw
    lienzo = Image.new("RGBA", (600, 120), (0, 0, 0, 0))
    lienzo.paste(logo.resize((108, 108), Image.LANCZOS), (6, 6), logo.resize((108, 108), Image.LANCZOS))
    dibujo = ImageDraw.Draw(lienzo)
    dibujo.text((132, 8), "CRIPTO", font=_fuente(56, True), fill=color_texto)
    dibujo.text((134, 66), "Soporte", font=_fuente(40, False), fill=color_soporte)
    return lienzo


def aplicar_windows() -> None:
    from PIL import Image

    # 1) Datos del ejecutable (Propiedades → Detalles en Windows).
    rc = RAIZ / "flutter" / "windows" / "runner" / "Runner.rc"
    cambios_rc = [
        (r'VALUE "CompanyName", "[^"]*"', f'VALUE "CompanyName", "{EMPRESA}"', "Empresa en el ejecutable"),
        (r'VALUE "FileDescription", "[^"]*"', f'VALUE "FileDescription", "{NOMBRE_APP}"', "Descripción del ejecutable"),
        (r'VALUE "ProductName", "[^"]*"', f'VALUE "ProductName", "{NOMBRE_APP}"', "Nombre del producto"),
        (r'VALUE "LegalCopyright", "[^"]*"',
         f'VALUE "LegalCopyright", "© 2026 {EMPRESA} - Basado en RustDesk (AGPL-3.0)"', "Derechos en el ejecutable"),
    ]
    for patron, nuevo, descripcion in cambios_rc:
        reemplazar_una_vez(rc, patron, nuevo, descripcion)

    # 2) Íconos de Windows (.ico con todos los tamaños) y del interior de la app.
    logo = _logo_transparente()
    tamanos_ico = [(16, 16), (20, 20), (24, 24), (32, 32), (40, 40), (48, 48), (64, 64), (128, 128), (256, 256)]
    destinos_ico = [
        RAIZ / "res" / "icon.ico",
        RAIZ / "res" / "tray-icon.ico",
        RAIZ / "flutter" / "windows" / "runner" / "resources" / "app_icon.ico",
    ]
    for destino in destinos_ico:
        if not destino.exists():
            error(f"No existe {destino.relative_to(RAIZ)}. ¿Cambió la estructura de RustDesk?")
        logo.resize((256, 256), Image.LANCZOS).save(destino, format="ICO", sizes=tamanos_ico)
    ok("Íconos de Windows (.ico) con el logo CRIPTO")
    logo.resize((1024, 1024), Image.LANCZOS).save(RAIZ / "res" / "icon.png", optimize=True)
    logo.resize((256, 256), Image.LANCZOS).save(RAIZ / "flutter" / "assets" / "icon.png", optimize=True)
    ok("Ícono interno de la app (assets/icon.png)")

    # 3) Logo con nombre dentro de la app: la marca siempre visible.
    activos = RAIZ / "flutter" / "assets"
    _logo_con_nombre(logo, (15, 23, 42), (37, 99, 235)).save(activos / "logo.png", optimize=True)
    _logo_con_nombre(logo, (15, 23, 42), (37, 99, 235)).save(activos / "logo_light.png", optimize=True)
    _logo_con_nombre(logo, (255, 255, 255), (96, 165, 250)).save(activos / "logo_dark.png", optimize=True)
    ok("Logo CRIPTO Soporte en la pantalla principal (tema claro y oscuro)")

    # 4) Lo mejor por defecto y servidor bloqueado.
    config = RAIZ / "libs" / "hbb_common" / "src" / "config.rs"
    reemplazar_una_vez(
        config,
        r"pub static ref DEFAULT_DISPLAY_SETTINGS: RwLock<HashMap<String, String>> = Default::default\(\);",
        "pub static ref DEFAULT_DISPLAY_SETTINGS: RwLock<HashMap<String, String>> = "
        + _mapa_rust(AJUSTES_IMAGEN_CRIPTO) + ";",
        "Calidad máxima por defecto (mejor imagen, 60 fps, 4:4:4, ajustar a la ventana)",
    )
    reemplazar_una_vez(
        config,
        r"pub static ref BUILTIN_SETTINGS: RwLock<HashMap<String, String>> = Default::default\(\);",
        "pub static ref BUILTIN_SETTINGS: RwLock<HashMap<String, String>> = "
        + _mapa_rust(AJUSTES_FIJOS_CRIPTO) + ";",
        "Ajustes de servidor ocultos (servidor propio fijo)",
    )


def main() -> None:
    windows = "--windows" in sys.argv[1:]
    print(f"[CRIPTO] Aplicando marca CRIPTO Soporte ({'Windows' if windows else 'Android'})…")
    servidor, llave = leer_secretos()
    aplicar_servidor(servidor, llave)
    if windows:
        aplicar_windows()
    else:
        aplicar_android()
        aplicar_iconos()
        aplicar_flutter()
    print("[CRIPTO] Marca aplicada correctamente.")


if __name__ == "__main__":
    main()

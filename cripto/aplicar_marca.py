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
#   v1.5  25/11/2026  Windows: nombre interno «CRIPTO-Soporte» (con guion),
#                     porque el instalador de Windows solo acepta letras,
#                     números, guion y guion bajo (medida de seguridad de
#                     RustDesk); el nombre visible sigue «CRIPTO Soporte».
#                     Windows: la app reconoce el servidor propio fijo como
#                     servidor privado (antes lo trataba como público, lo que
#                     limitaba la calidad y mostraba «configure su propio
#                     servidor»). Android no cambia.
#   v1.6  25/11/2026  Android: ícono de la notificación (barra superior y
#                     pantalla bloqueada) con la silueta del logo CRIPTO en
#                     lugar del de RustDesk, en las 5 densidades, y color de
#                     acento de la notificación con el azul de la marca.
#   v1.7  25/11/2026  Windows, fase 2 (cripto_tecnico.dart): panel «Dar
#                     soporte» con la elección Técnico / Acompañante en la
#                     pantalla principal, rol aplicado al abrir cada sesión
#                     (el acompañante entra en modo solo ver) y confirmación
#                     del permiso del cliente antes de grabar. Android no
#                     cambia.
#   v1.8  25/11/2026  El logo transparente ya no exige numpy (solo Pillow,
#                     que es lo que instala el workflow de Android). Corrige
#                     el fallo de la compilación Android #8.
#   v1.9  25/11/2026  Windows, fase publicidad (cripto_publicidad.dart):
#                     tarjeta de publicidad que rota (CRIPTO ERP y PCGreen),
#                     logo de CRIPTO Software al pie y aviso de bienvenida una
#                     vez al día; todos los enlaces a pc-green.com. El crédito
#                     «Con tecnología de RustDesk» se mantiene (licencia AGPL)
#                     pero ahora lleva a pc-green.com y se lee mejor. Colores
#                     CRIPTO (azul #2563EB) en toda la app, incluida la barra
#                     de la sesión. Barra izquierda más ancha (240 px).
#                     Android no cambia.
#   v2.0  26/11/2026  Windows: publicidad por nichos y WhatsApp de soporte
#                     (cripto_publicidad.dart v2.0). El logo «CRIPTO Soporte»
#                     de la barra izquierda queda centrado (se recorta el
#                     espacio vacío que tenía a la derecha). Barra izquierda
#                     de 260 px para que la tarjeta de publicidad se lea
#                     cómoda. Android no cambia.
#   v2.1  26/11/2026  Ícono propio de CRIPTO Soporte (logo CRIPTO con
#                     audífonos de soporte, fondo blanco) para que no se
#                     confunda con el ícono de CRIPTO ERP. Archivo nuevo
#                     cripto/marca/icono_soporte_1024.png. Se aplica en
#                     Android (ícono clásico, redondo y adaptable con fondo
#                     blanco) y en Windows (ejecutable, bandeja y barra de
#                     tareas). El logo con nombre de la pantalla principal y
#                     el ícono de la notificación de Android no cambian.
#   v2.2  26/11/2026  Windows: el ícono con audífonos va TRANSPARENTE (sin el
#                     cuadro blanco), igual que el acceso de CRIPTO Software en
#                     el escritorio; antes se veía como una imagen pegada.
#                     Android no cambia: allí el sistema pone cada ícono dentro
#                     de una forma (círculo o cuadro), por eso lleva fondo blanco.
#   v2.3  26/11/2026  Licencias y pases (cripto/rust/cripto_licencia.rs y
#                     cripto/flutter/cripto_licencia.dart). Android: la app
#                     del celular RECHAZA toda conexión que no traiga un pase
#                     válido del servidor de licencias de PCG SAS (sin pase o
#                     sin internet = rechazo) y avisa el fin de cada sesión.
#                     Windows: el programa del técnico pide un pase antes de
#                     cada conexión si tiene licencia, y muestra «Activar
#                     licencia de técnico» bajo «Dar soporte». Sin licencia
#                     el soporte entre PC funciona igual que antes. Se agrega
#                     el campo cripto_pase (número 50) a LoginRequest.
# ============================================================

import os
import re
import shutil
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent

NOMBRE_APP = "CRIPTO Soporte"
NOMBRE_SERVICIO = "CRIPTO Soporte Control"
NOMBRE_INTERNO_WINDOWS = "CRIPTO-Soporte"  # v1.5 — el instalador de Windows no acepta espacios
APP_ID_ORIGINAL = "com.carriez.flutter_hbb"
APP_ID_CRIPTO = "com.criptosoftware.soporte"
COLOR_FONDO_ICONO = "#FFFFFF"  # v2.1 — fondo blanco del ícono con audífonos (antes #0B1029)
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


def aplicar_servidor(servidor: str, llave: str, nombre_interno: str = NOMBRE_APP) -> None:
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
        f'APP_NAME: RwLock<String> = RwLock::new("{nombre_interno}".to_owned());',
        f"Nombre interno de la app ({nombre_interno})",
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

    # v2.1 — Ícono propio de CRIPTO Soporte (logo con audífonos, fondo blanco).
    # Antes se usaban icono_1024.png e ic_launcher_foreground_432.png (iguales
    # al ícono del ERP); esos archivos se conservan en cripto/marca/.
    contenido = _icono_soporte_transparente()
    res = RAIZ / "flutter" / "android" / "app" / "src" / "main" / "res"

    for carpeta, lado_icono, lado_primer_plano in TAMANOS:
        destino = res / carpeta
        if not destino.is_dir():
            error(f"No existe la carpeta de íconos {destino.relative_to(RAIZ)}.")
        # Ícono adaptable: el dibujo va dentro de la zona segura (66 % central)
        # sobre fondo transparente; el fondo blanco lo pone ic_launcher_background.
        primer_plano = Image.new("RGBA", (lado_primer_plano, lado_primer_plano), (0, 0, 0, 0))
        tam = int(lado_primer_plano * 0.66)
        primer_plano.alpha_composite(contenido.resize((tam, tam), Image.LANCZOS),
                                     ((lado_primer_plano - tam) // 2, (lado_primer_plano - tam) // 2))
        primer_plano.save(destino / "ic_launcher_foreground.png", optimize=True)
        _icono_soporte_baldosa(lado_icono).save(destino / "ic_launcher.png", optimize=True)
        _icono_soporte_baldosa(lado_icono, redondo=True, ocupa=0.74).save(
            destino / "ic_launcher_round.png", optimize=True)
    ok("Íconos de CRIPTO Soporte (con audífonos) en las 5 densidades de Android")

    # v1.6 — Ícono de la notificación: Android exige una silueta blanca sobre
    # fondo transparente (él la pinta con el color de acento).
    logo = _logo_transparente()
    canal_alfa = logo.split()[3]
    tamanos_notificacion = [("mipmap-mdpi", 24), ("mipmap-hdpi", 36), ("mipmap-xhdpi", 48),
                            ("mipmap-xxhdpi", 72), ("mipmap-xxxhdpi", 96)]
    for carpeta, lado in tamanos_notificacion:
        destino = res / carpeta / "ic_stat_logo.png"
        if not destino.exists():
            error(f"No existe {destino.relative_to(RAIZ)} (ícono de notificación de RustDesk).")
        alfa = canal_alfa.resize((lado, lado), Image.LANCZOS)
        silueta = Image.new("RGBA", (lado, lado), (255, 255, 255, 0))
        silueta.putalpha(alfa)
        silueta.save(destino, optimize=True)
    ok("Ícono de la notificación con la silueta del logo CRIPTO")
    reemplazar_una_vez(
        res / "values" / "colors.xml",
        r'<color name="primary">#[0-9A-Fa-f]{6,8}</color>',
        '<color name="primary">#FF2563EB</color>',
        "Color de acento de la notificación (azul CRIPTO)",
    )


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
    """Quita el fondo azul de icono_1024.png y deja solo el logo (RGBA, recortado).
    v1.8: solo necesita Pillow (numpy es opcional y acelera si está instalado)."""
    try:
        from PIL import Image
    except ImportError:
        error("Falta la librería Pillow (pip install pillow).")
    origen = RAIZ / "cripto" / "marca" / "icono_1024.png"
    if not origen.exists():
        error(f"Falta el archivo de marca {origen.relative_to(RAIZ)}.")
    base = Image.open(origen).convert("RGB")
    fr, fg, fb = COLOR_FONDO_RGB
    try:
        import numpy as np
        rgb = np.array(base).astype(float)
        fondo = np.array(COLOR_FONDO_RGB, dtype=float)
        distancia = np.sqrt(((rgb - fondo) ** 2).sum(axis=2))
        alfa = np.clip((distancia - 6) * 4, 0, 255)
        a = alfa[..., None] / 255.0
        color = np.where(a > 0.01, (rgb - fondo * (1 - a)) / np.maximum(a, 0.01), 0)
        imagen = Image.fromarray(np.dstack([np.clip(color, 0, 255), alfa]).astype("uint8"), "RGBA")
    except ImportError:
        pixeles = []
        for r, g, b in base.getdata():
            distancia = ((r - fr) ** 2 + (g - fg) ** 2 + (b - fb) ** 2) ** 0.5
            alfa = max(0.0, min(255.0, (distancia - 6) * 4))
            a = alfa / 255.0
            if a > 0.01:
                c = [max(0, min(255, int((v - f * (1 - a)) / a))) for v, f in ((r, fr), (g, fg), (b, fb))]
            else:
                c = [0, 0, 0]
            pixeles.append((c[0], c[1], c[2], int(alfa)))
        imagen = Image.new("RGBA", base.size)
        imagen.putdata(pixeles)
    caja = imagen.getbbox()
    if not caja:
        error("No se pudo separar el logo del fondo en icono_1024.png.")
    imagen = imagen.crop(caja)
    lado = max(imagen.size)
    margen = int(lado * 0.04)
    cuadro = Image.new("RGBA", (lado + 2 * margen, lado + 2 * margen), (0, 0, 0, 0))
    cuadro.paste(imagen, ((lado - imagen.size[0]) // 2 + margen, (lado - imagen.size[1]) // 2 + margen))
    return cuadro


def _icono_soporte_original():
    """v2.1 — Ícono de CRIPTO Soporte (logo con audífonos, fondo blanco)."""
    try:
        from PIL import Image
    except ImportError:
        error("Falta la librería Pillow (pip install pillow).")
    origen = RAIZ / "cripto" / "marca" / "icono_soporte_1024.png"
    if not origen.exists():
        error(f"Falta el archivo de marca {origen.relative_to(RAIZ)} (ícono con audífonos).")
    return Image.open(origen).convert("RGB")


def _icono_soporte_transparente():
    """v2.1 — Logo con audífonos sin el fondo blanco (RGBA, recortado y cuadrado)."""
    from PIL import Image
    base = _icono_soporte_original()
    pixeles = []
    for r, g, b in base.getdata():
        # Cuanto más se aleja del blanco, más opaco; se recupera el color real.
        alfa = max(0.0, min(255.0, (255 - min(r, g, b) - 4) * 3.0))
        a = alfa / 255.0
        if a > 0.01:
            c = [max(0, min(255, int((v - 255 * (1 - a)) / a))) for v in (r, g, b)]
        else:
            c = [0, 0, 0]
        pixeles.append((c[0], c[1], c[2], int(alfa)))
    imagen = Image.new("RGBA", base.size)
    imagen.putdata(pixeles)
    caja = imagen.getbbox()
    if not caja:
        error("No se pudo separar el ícono con audífonos del fondo blanco.")
    imagen = imagen.crop(caja)
    lado = max(imagen.size)
    cuadro = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    cuadro.paste(imagen, ((lado - imagen.size[0]) // 2, (lado - imagen.size[1]) // 2))
    return cuadro


def _icono_soporte_baldosa(lado: int, redondo: bool = False, ocupa: float = 0.80):
    """v2.1 — Ícono con audífonos sobre fondo blanco (esquinas redondeadas o círculo)."""
    from PIL import Image, ImageDraw
    escala = 4
    grande = lado * escala
    contenido = _icono_soporte_transparente()
    tam = int(grande * ocupa)
    contenido = contenido.resize((tam, tam), Image.LANCZOS)
    fondo = Image.new("RGBA", (grande, grande), (255, 255, 255, 255))
    fondo.alpha_composite(contenido, ((grande - tam) // 2, (grande - tam) // 2))
    mascara = Image.new("L", (grande, grande), 0)
    if redondo:
        ImageDraw.Draw(mascara).ellipse((0, 0, grande - 1, grande - 1), fill=255)
    else:
        ImageDraw.Draw(mascara).rounded_rectangle((0, 0, grande - 1, grande - 1),
                                                   radius=int(grande * 0.22), fill=255)
    salida = Image.new("RGBA", (grande, grande), (0, 0, 0, 0))
    salida.paste(fondo, (0, 0), mascara)
    return salida.resize((lado, lado), Image.LANCZOS)


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
    # v2.0 — Se recorta el espacio vacío de la derecha para que el logo quede
    # centrado en la barra izquierda (antes se veía corrido a la izquierda).
    caja = lienzo.getbbox()
    if caja:
        izquierda, _, derecha, _ = caja
        lienzo = lienzo.crop((max(0, izquierda - 6), 0, min(600, derecha + 6), 120))
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
    icono_win = _icono_soporte_transparente()  # v2.2
    tamanos_ico = [(16, 16), (20, 20), (24, 24), (32, 32), (40, 40), (48, 48), (64, 64), (128, 128), (256, 256)]
    destinos_ico = [
        RAIZ / "res" / "icon.ico",
        RAIZ / "res" / "tray-icon.ico",
        RAIZ / "flutter" / "windows" / "runner" / "resources" / "app_icon.ico",
    ]
    for destino in destinos_ico:
        if not destino.exists():
            error(f"No existe {destino.relative_to(RAIZ)}. ¿Cambió la estructura de RustDesk?")
        # v2.1 — Ícono propio con audífonos para no confundirlo con el ERP.
        # v2.2 — Transparente (sin cuadro blanco), como el de CRIPTO Software.
        icono_win.resize((256, 256), Image.LANCZOS).save(destino, format="ICO", sizes=tamanos_ico)
    ok("Íconos de Windows (.ico) transparentes con el ícono de CRIPTO Soporte (audífonos)")
    icono_win.resize((1024, 1024), Image.LANCZOS).save(RAIZ / "res" / "icon.png", optimize=True)
    icono_win.resize((256, 256), Image.LANCZOS).save(RAIZ / "flutter" / "assets" / "icon.png", optimize=True)
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

    # 6) v1.7 — Fase 2: panel del técnico, roles y grabación con permiso.
    aplicar_windows_fase2()
    # 7) v1.9 — Publicidad de CRIPTO Software y colores de la marca.
    aplicar_windows_publicidad()
    # 8) v2.3 — Activación de la licencia de técnico (bajo «Dar soporte»).
    aplicar_windows_licencia()

    # 5) v1.5 — El servidor fijo es privado: sin límites de calidad de servidor público.
    reemplazar_una_vez(
        RAIZ / "src" / "common.rs",
        r'crate::get_custom_rendezvous_server\(get_option\("custom-rendezvous-server"\)\)\.is_empty\(\)',
        "false // CRIPTO: siempre servidor propio (privado)",
        "Servidor propio reconocido como privado (calidad completa)",
    )


def aplicar_windows_fase2() -> None:
    """v1.7 — Pantallas y reglas propias de CRIPTO en el programa del técnico."""
    origen = RAIZ / "cripto" / "flutter" / "cripto_tecnico.dart"
    if not origen.exists():
        error(f"Falta el archivo {origen.relative_to(RAIZ)}.")
    destino = RAIZ / "flutter" / "lib" / "cripto"
    destino.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(origen, destino / "cripto_tecnico.dart")
    ok("Pantallas del técnico copiadas a flutter/lib/cripto/")

    lib = RAIZ / "flutter" / "lib"
    # Panel «Dar soporte» (Técnico / Acompañante) sobre el número del cliente.
    conexion = lib / "desktop" / "pages" / "connection_page.dart"
    reemplazar_una_vez(
        conexion,
        r"(?m)^(import '\.\./\.\./common\.dart';)$",
        "import '../../common.dart';\nimport '../../cripto/cripto_tecnico.dart';",
        "Importación del panel del técnico",
    )
    reemplazar_una_vez(
        conexion,
        r"Row\(\s*children: \[\s*Flexible\(child: _buildRemoteIDTextField\(context\)\),\s*\],\s*\)\.marginOnly\(top: 22\),",
        "const CriptoPanelTecnico(),\n"
        "            Row(children: [Flexible(child: _buildRemoteIDTextField(context))])"
        ".marginOnly(top: 16),",
        "Panel «Dar soporte» con Técnico / Acompañante",
    )

    # Rol aplicado al abrir la sesión (Acompañante = solo ver).
    modelo = lib / "models" / "model.dart"
    reemplazar_una_vez(
        modelo,
        r"(?m)^(import '\.\./common\.dart';)$",
        "import '../common.dart';\nimport '../cripto/cripto_tecnico.dart';",
        "Importación del rol del técnico (modelo)",
    )
    reemplazar_una_vez(
        modelo,
        r"setViewOnly\(\s*peerId,\s*bind\.sessionGetToggleOptionSync\(\s*sessionId: sessionId, arg: kOptionToggleViewOnly\)\);",
        "setViewOnly(peerId, criptoAplicarRol(sessionId, peerId));",
        "Rol Técnico / Acompañante aplicado a cada sesión",
    )

    # Grabación solo con el permiso del cliente.
    barra = lib / "desktop" / "widgets" / "remote_toolbar.dart"
    reemplazar_una_vez(
        barra,
        r"(?m)^(import '\.\./\.\./common\.dart';)$",
        "import '../../common.dart';\nimport '../../cripto/cripto_tecnico.dart';",
        "Importación de la confirmación de grabación",
    )
    reemplazar_una_vez(
        barra,
        r"onPressed: \(\) => recordingModel\.toggle\(\),",
        "onPressed: () async {\n"
        "        if (recordingModel.start || await criptoConfirmarGrabacion(context)) {\n"
        "          recordingModel.toggle();\n"
        "        }\n"
        "      },",
        "Grabación solo con permiso del cliente",
    )


def aplicar_windows_publicidad() -> None:
    """v1.9 — Publicidad de CRIPTO Software y colores de la marca (solo Windows)."""
    origen = RAIZ / "cripto" / "flutter" / "cripto_publicidad.dart"
    if not origen.exists():
        error(f"Falta el archivo {origen.relative_to(RAIZ)}.")
    destino = RAIZ / "flutter" / "lib" / "cripto"
    destino.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(origen, destino / "cripto_publicidad.dart")
    logo = RAIZ / "cripto" / "marca" / "logo_cripto_software.png"
    if not logo.exists():
        error(f"Falta el archivo de marca {logo.relative_to(RAIZ)}.")
    shutil.copyfile(logo, RAIZ / "flutter" / "assets" / "cripto_software.png")
    ok("Publicidad y logo de CRIPTO Software copiados")

    lib = RAIZ / "flutter" / "lib"
    comun = lib / "common.dart"
    # Crédito de RustDesk (AGPL): se mantiene, pero lleva a la página de CRIPTO.
    reemplazar_una_vez(
        comun,
        r"launchUrl\(Uri\.parse\('https://rustdesk\.com'\)\);(\s*\},\s*child: Opacity\(\s*)opacity: 0\.5,",
        "launchUrl(Uri.parse('https://pc-green.com'));\n      },\n      child: Opacity(\n          opacity: 0.85,",
        "Crédito «Con tecnología de RustDesk» con enlace a pc-green.com",
    )
    # Colores de la marca CRIPTO en toda la app (también en la barra de la sesión).
    for patron, nuevo, descripcion in [
        (r"static const Color accent = Color\(0xFF0071FF\);",
         "static const Color accent = Color(0xFF2563EB);", "Color principal CRIPTO"),
        (r"static const Color accent50 = Color\(0x770071FF\);",
         "static const Color accent50 = Color(0x772563EB);", "Color principal CRIPTO (50 %)"),
        (r"static const Color accent80 = Color\(0xAA0071FF\);",
         "static const Color accent80 = Color(0xAA2563EB);", "Color principal CRIPTO (80 %)"),
        (r"static const Color button = Color\(0xFF2C8CFF\);",
         "static const Color button = Color(0xFF2563EB);", "Color de los botones CRIPTO"),
        (r"static const Color idColor = Color\(0xFF00B6F0\);",
         "static const Color idColor = Color(0xFF1D4ED8);", "Color del ID CRIPTO"),
    ]:
        reemplazar_una_vez(comun, patron, nuevo, descripcion)

    # Panel de publicidad en la barra izquierda de la pantalla principal.
    inicio = lib / "desktop" / "pages" / "desktop_home_page.dart"
    reemplazar_una_vez(
        inicio,
        r"(?m)^import '\.\./widgets/button\.dart';$",
        "import '../widgets/button.dart';\nimport '../../cripto/cripto_publicidad.dart';",
        "Importación de la publicidad CRIPTO",
    )
    reemplazar_una_vez(
        inicio,
        r"\n    \];\n    if \(isIncomingOnly\) \{\n      children\.addAll\(\[",
        "\n      if (!isIncomingOnly) const CriptoPanelPublicidad(),\n    ];\n"
        "    if (isIncomingOnly) {\n      children.addAll([",
        "Panel de publicidad en la barra izquierda",
    )
    reemplazar_una_vez(
        inicio,
        r"width: isIncomingOnly \? 280\.0 : 200\.0,",
        "width: isIncomingOnly ? 280.0 : 260.0,",  # v2.0: 260 px (antes 240)
        "Barra izquierda más ancha para la publicidad",
    )


def aplicar_licencia() -> None:
    """v2.3 — «Enchufe» con el servidor de licencias (Android y Windows).

    El código de RustDesk solo cambia en 5 puntos pequeños; toda la lógica
    está en cripto/rust/cripto_licencia.rs y en el servidor de PCG SAS.
    """
    origen = RAIZ / "cripto" / "rust" / "cripto_licencia.rs"
    if not origen.exists():
        error(f"Falta el archivo {origen.relative_to(RAIZ)}.")
    shutil.copyfile(origen, RAIZ / "src" / "cripto_licencia.rs")
    ok("Módulo de licencias copiado a src/cripto_licencia.rs")

    reemplazar_una_vez(
        RAIZ / "src" / "lib.rs",
        r"(?m)^mod hbbs_http;$",
        "mod hbbs_http;\nmod cripto_licencia; // CRIPTO v2.3",
        "Registro del módulo de licencias",
    )

    # Campo nuevo en la solicitud de conexión (los equipos sin él lo ignoran).
    reemplazar_una_vez(
        RAIZ / "libs" / "base" / "protos" / "message.proto",
        r"(  bool trusted_device_v2_supported = 19;\n)\}",
        "  bool trusted_device_v2_supported = 19;\n"
        "  string cripto_pase = 50; // CRIPTO: pase de licencia de un solo uso\n}",
        "Campo cripto_pase en LoginRequest",
    )

    # Programa del técnico: pide el pase y lo pone en la solicitud de conexión.
    reemplazar_una_vez(
        RAIZ / "src" / "client.rs",
        r"let msg_out = lc\s*\.read\(\)\s*\.unwrap\(\)\s*\.create_login_msg\(os_username, os_password, password\);",
        "let mut msg_out = lc\n"
        "        .read()\n"
        "        .unwrap()\n"
        "        .create_login_msg(os_username, os_password, password);\n"
        "    // CRIPTO v2.3: pase de licencia de un solo uso (vacío si no hay licencia).\n"
        "    let cripto_destino = lc.read().unwrap().id.clone();\n"
        "    let cripto_pase = crate::cripto_licencia::pedir_pase(&cripto_destino).await;\n"
        "    if !cripto_pase.is_empty() {\n"
        "        if let Some(base::message_proto::message::Union::LoginRequest(lr)) = msg_out.union.as_mut() {\n"
        "            lr.cripto_pase = cripto_pase;\n"
        "        }\n"
        "    }",
        "El técnico pide el pase antes de conectar",
    )

    conexion = RAIZ / "src" / "server" / "connection.rs"
    # App del celular: sin pase válido no entra nadie (antes de mostrar nada).
    reemplazar_una_vez(
        conexion,
        r"(if !self\.check_login_scope\(&lr\)\.await \{\s*return false;\s*\})",
        "if !self.check_login_scope(&lr).await {\n"
        "                return false;\n"
        "            }\n"
        "            // CRIPTO v2.3: en el celular solo entra un técnico con pase válido.\n"
        "            #[cfg(target_os = \"android\")]\n"
        "            if !crate::cripto_licencia::validar_pase(&lr.my_id, &lr.cripto_pase).await {\n"
        "                self.send_login_error(crate::cripto_licencia::MENSAJE_BLOQUEO).await;\n"
        "                sleep(1.).await;\n"
        "                return false;\n"
        "            }",
        "El celular valida el pase de cada conexión",
    )
    reemplazar_una_vez(
        conexion,
        r"async fn on_close\(&mut self, reason: &str, lock: bool\) \{",
        "async fn on_close(&mut self, reason: &str, lock: bool) {\n"
        "        // CRIPTO v2.3: el celular registra el fin de la sesión.\n"
        "        #[cfg(target_os = \"android\")]\n"
        "        if self.authorized {\n"
        "            crate::cripto_licencia::avisar_fin_sesion(self.lr.my_id.clone());\n"
        "        }",
        "El celular avisa el fin de la sesión",
    )


def aplicar_windows_licencia() -> None:
    """v2.3 — Línea «Activar licencia de técnico» bajo «Dar soporte» (solo Windows)."""
    origen = RAIZ / "cripto" / "flutter" / "cripto_licencia.dart"
    if not origen.exists():
        error(f"Falta el archivo {origen.relative_to(RAIZ)}.")
    destino = RAIZ / "flutter" / "lib" / "cripto"
    destino.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(origen, destino / "cripto_licencia.dart")
    ok("Pantalla de licencia del técnico copiada")

    conexion = RAIZ / "flutter" / "lib" / "desktop" / "pages" / "connection_page.dart"
    reemplazar_una_vez(
        conexion,
        r"(?m)^import '\.\./\.\./cripto/cripto_tecnico\.dart';$",
        "import '../../cripto/cripto_tecnico.dart';\nimport '../../cripto/cripto_licencia.dart';",
        "Importación de la licencia del técnico",
    )
    reemplazar_una_vez(
        conexion,
        r"const CriptoPanelTecnico\(\),",
        "const CriptoPanelTecnico(),\n            const CriptoLicenciaTecnico(),",
        "Línea de licencia bajo «Dar soporte»",
    )


def main() -> None:
    windows = "--windows" in sys.argv[1:]
    print(f"[CRIPTO] Aplicando marca CRIPTO Soporte ({'Windows' if windows else 'Android'})…")
    servidor, llave = leer_secretos()
    aplicar_servidor(servidor, llave, NOMBRE_INTERNO_WINDOWS if windows else NOMBRE_APP)
    aplicar_licencia()  # v2.3 — pases de licencia (Android valida, Windows pide)
    if windows:
        aplicar_windows()
    else:
        aplicar_android()
        aplicar_iconos()
        aplicar_flutter()
    print("[CRIPTO] Marca aplicada correctamente.")


if __name__ == "__main__":
    main()

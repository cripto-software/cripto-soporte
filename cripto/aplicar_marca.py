# ============================================================
# 📁 RUTA   : cripto/aplicar_marca.py
# 📌 ARCHIVO: aplicar_marca.py
# 📝 RESUMEN: Aplica la marca CRIPTO Soporte al código antes de
#             compilar la app de Android: servidor y llave pública
#             (leídos de los Secrets de GitHub), nombre de la app,
#             identificador com.criptosoftware.soporte e íconos.
#             Si algo no coincide, detiene la compilación con un
#             mensaje claro. Nunca imprime el servidor ni la llave.
# 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
# ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
#    (Este archivo forma parte de un trabajo derivado de RustDesk,
#     distribuido bajo la licencia AGPL-3.0.)
# ------------------------------------------------------------
# Historial
#   v1.0  23/11/2026  Versión inicial.
# ============================================================

import os
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent

NOMBRE_APP = "CRIPTO Soporte"
NOMBRE_SERVICIO = "CRIPTO Soporte Control"
APP_ID_ORIGINAL = "com.carriez.flutter_hbb"
APP_ID_CRIPTO = "com.criptosoftware.soporte"
COLOR_FONDO_ICONO = "#0B1029"

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
    manifiesto = android / "src" / "main" / "AndroidManifest.xml"
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


def main() -> None:
    print("[CRIPTO] Aplicando marca CRIPTO Soporte…")
    servidor, llave = leer_secretos()
    aplicar_servidor(servidor, llave)
    aplicar_android()
    aplicar_iconos()
    print("[CRIPTO] Marca aplicada correctamente.")


if __name__ == "__main__":
    main()

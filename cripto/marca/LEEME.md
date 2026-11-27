# CRIPTO Soporte — archivos de marca

<!--
📁 RUTA   : cripto/marca/LEEME.md
📝 RESUMEN: Explica los archivos de marca, cómo se compila la app, qué
            parte del código es pública y quién es dueño de la marca CRIPTO.
👤 AUTOR  : Téc. Sup. Pablo Quichimbo — PCG SAS
©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
-->

Esta carpeta guarda la marca de **CRIPTO Soporte**:

| Archivo | Uso |
|---|---|
| `icono_1024.png` | Ícono clásico y redondo de Android (se reduce a 48–192 px) |
| `ic_launcher_foreground_432.png` | Primer plano del ícono adaptable de Android (108–432 px) |
| `icono_soporte_1024.png` | Ícono propio de CRIPTO Soporte (logo CRIPTO con audífonos) para Android y Windows |
| `logo_cripto_software.png` | Logo de CRIPTO Software que aparece en la publicidad del programa de Windows |

## Cómo se compila

1. Pestaña **Actions** → **CRIPTO Soporte - Android** → **Run workflow**.
2. El flujo `.github/workflows/cripto-android.yml` ejecuta `cripto/aplicar_marca.py`, que:
   - toma el servidor y la llave pública de los Secrets `RENDEZVOUS_SERVER` y `RS_PUB_KEY`;
   - cambia el nombre a «CRIPTO Soporte» y el identificador a `com.criptosoftware.soporte`;
   - genera los íconos a partir de esta carpeta.
3. La APK queda para descargar en la ejecución, sección **Artifacts**.

El programa de Windows se compila igual con **CRIPTO Soporte - Windows**
(`.github/workflows/cripto-windows.yml`), que ejecuta `cripto/aplicar_marca.py --windows`.

## Qué hay en la carpeta `cripto/`

Todo lo propio de CRIPTO Soporte vive en `cripto/`; el código de RustDesk se
modifica solo en puntos pequeños al momento de compilar.

| Carpeta | Contenido |
|---|---|
| `cripto/aplicar_marca.py` | Aplica la marca y conecta las piezas de CRIPTO al compilar |
| `cripto/flutter/` | Pantallas de CRIPTO (privacidad, publicidad, técnico, licencia, etc.) |
| `cripto/rust/` | Conexión con el servidor de licencias de PCG S.A.S. (pases de un solo uso) |
| `cripto/marca/` | Íconos y logos (ver la sección **Marca**) |

Las licencias, los pases y los registros de cada conexión se administran en el
servidor de PCG S.A.S.; ese servidor **no** forma parte de este repositorio.

## Seguridad

- El servidor y la llave **no** se escriben en este repositorio: solo viven cifrados en los Secrets.
- La llave privada del servidor (`id_ed25519`) **nunca** sale del VPS.
- Firma de la APK: secrets `ANDROID_SIGNING_KEY`, `ANDROID_ALIAS`, `ANDROID_KEY_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`.
- El soporte a celulares solo lo pueden dar técnicos con licencia y pase válido emitidos por PCG S.A.S.

## Licencia

CRIPTO Soporte es un trabajo derivado de [RustDesk](https://github.com/rustdesk/rustdesk),
distribuido bajo la licencia **AGPL-3.0**. El código fuente completo está en este repositorio.

## Marca

La licencia AGPL-3.0 cubre el **código fuente**, no las marcas.

**CRIPTO**, **CRIPTO Soporte**, **CRIPTO Software**, **CRIPTO ERP**, **PCGreen**,
sus logotipos e íconos (los archivos de esta carpeta y los que el programa
muestra) son marcas de **PCG S.A.S.** (RUC 1793191831001, Quito – Ecuador).

- No se permite usar estos nombres, logotipos ni íconos en otros programas,
  versiones modificadas, páginas o servicios sin autorización escrita de PCG S.A.S.
- Quien publique una versión modificada de este código debe quitar las marcas
  y los logotipos de CRIPTO y usar un nombre propio, para que nadie la confunda
  con el producto oficial.
- La app oficial solo se distribuye en Google Play (cuenta de PCG S.A.S.) y en
  [pc-green.com/descargas](https://pc-green.com/descargas).

Consultas sobre la marca: soporte@pc-green.com.

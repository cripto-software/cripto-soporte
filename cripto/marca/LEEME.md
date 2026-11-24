CRIPTO Soporte — archivos de marca
<!--
📁 RUTA   : cripto/marca/LEEME.md
📝 RESUMEN: Explica los archivos de marca y cómo se compila la app.
👤 AUTOR  : Téc. Sup. Pablo Quichimbo — PCG SAS
©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
Esta carpeta guarda la marca de CRIPTO Soporte:
Archivo	Uso
`icono_1024.png`	Ícono clásico y redondo de Android (se reduce a 48–192 px)
`ic_launcher_foreground_432.png`	Primer plano del ícono adaptable de Android (108–432 px)
Cómo se compila
Pestaña Actions → CRIPTO Soporte - Android → Run workflow.
El flujo `.github/workflows/cripto-android.yml` ejecuta `cripto/aplicar_marca.py`, que:
toma el servidor y la llave pública de los Secrets `RENDEZVOUS_SERVER` y `RS_PUB_KEY`;
cambia el nombre a «CRIPTO Soporte» y el identificador a `com.criptosoftware.soporte`;
genera los íconos a partir de esta carpeta.
La APK queda para descargar en la ejecución, sección Artifacts.
Seguridad
El servidor y la llave no se escriben en este repositorio: solo viven cifrados en los Secrets.
La llave privada del servidor (`id_ed25519`) nunca sale del VPS.
Firma de la APK: secrets `ANDROID_SIGNING_KEY`, `ANDROID_ALIAS`, `ANDROID_KEY_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`.
Licencia
CRIPTO Soporte es un trabajo derivado de RustDesk,
distribuido bajo la licencia AGPL-3.0. El código fuente completo está en este repositorio.

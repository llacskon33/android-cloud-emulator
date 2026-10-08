# Android Cloud Emulator (app Android)

App Android nativa (Kotlin, Material Design 3, minSdk 28 / Android 9) que abre el emulador Android alojado en la nube mediante **WebView + noVNC**, a pantalla completa y con soporte táctil.

## Instalación

1. Descarga `cloud-emulator.apk` desde la sección **Releases** del repositorio (o desde los artefactos de GitHub Actions).
2. En el móvil permite *instalar apps de origen desconocido* para tu navegador/gestor de archivos.
3. Abre el APK e instala.

## Configurar la conexión

Al abrir la app introduce:

| Campo | Descripción |
|---|---|
| IP / dominio | Servidor donde corre el emulador (noVNC) |
| Puerto | Por defecto `6080` |
| Contraseña VNC | Opcional |
| Usar HTTPS | Actívalo si tu servidor está detrás de un proxy TLS |

Los datos se guardan localmente (SharedPreferences privadas) y la app conecta automáticamente al abrirse. Con la sesión activa, los botones superiores muestran el estado (Conectado/Conectando/Error), **Recargar** y **Desconectar**. La rotación de pantalla está permitida.

> Seguridad: noVNC en el puerto 6080 usa HTTP sin cifrar. En redes no confiables usa HTTPS, una VPN o un túnel SSH. La contraseña se envía en la URL de noVNC al servidor.

## Compilar

Requisitos: JDK 17 y Android SDK 34.

```bash
./gradlew assembleDebug     # app/build/outputs/apk/debug
./gradlew assembleRelease   # app/build/outputs/apk/release
```

## Generar un APK firmado

1. Crea un keystore:
   ```bash
   keytool -genkeypair -v -keystore release.jks -alias cloudemu -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Compila localmente con:
   ```bash
   KEYSTORE_FILE=$PWD/release.jks KEYSTORE_PASSWORD=... KEY_ALIAS=cloudemu KEY_PASSWORD=... ./gradlew assembleRelease
   ```
3. En GitHub Actions añade los secretos `KEYSTORE_BASE64` (`base64 -w0 release.jks`), `KEYSTORE_PASSWORD`, `KEY_ALIAS` y `KEY_PASSWORD`. Sin ellos el APK se firma con la clave de depuración (instalable, pero no apto para publicar en tiendas).

Nunca subas el keystore al repositorio.

## CI/CD

`.github/workflows/android.yml` compila el APK en cada push/PR, lo sube como artefacto y, en push, publica un release con `cloud-emulator.apk` (tags `v*` crean release estable; pushes a `main` crean un pre-release `build-N`).

## Licencia

MIT

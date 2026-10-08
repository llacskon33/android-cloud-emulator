# android-cloud-emulator

Emulador Android en la nube para ejecutar una máquina virtual Android con acceso remoto y instalación de APKs.

## Qué incluye

- Docker para levantar un entorno Android completo
- Android SDK + emulator + platform-tools
- ADB para instalar APKs
- noVNC para ver la pantalla del móvil desde el navegador
- Volumen `/apks` para subir aplicaciones

## Requisitos

- Docker
- Docker Compose

## Inicio rápido

```bash
docker compose up --build
```

Luego abre:

- http://localhost:6080/vnc.html

Para instalar un APK desde tu host:

```bash
cp mi-app.apk apks/
docker compose exec android-cloud-emulator /opt/install-apk.sh /apks/mi-app.apk
```

## Arquitectura

- Android se ejecuta dentro de un contenedor Docker
- La pantalla se expone por noVNC
- Los APKs se montan desde el directorio `apks/`
- El dispositivo se controla con ADB

## Notas

Este proyecto crea un entorno Android virtual potente y accesible desde la nube o desde un servidor local.

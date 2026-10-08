# Android Cloud Emulator

Android emulator (QEMU + KVM) in Docker, accessible from any browser via VNC/noVNC. Multi-stage image (Ubuntu 22.04, Android SDK, API 34 x86_64 Google APIs).

## Quick start (local)

```bash
cp .env.example .env     # set VNC_PASSWORD
docker compose up -d --build
```

Open <http://localhost:6080> and enter your VNC password. First boot takes a few minutes.
Without a `.env` password, a random one is printed in `docker logs android-emulator`.

Manual run:

```bash
docker run -d --device /dev/kvm -p 127.0.0.1:6080:6080 -e VNC_PASSWORD=secret \
  -v android-data:/data ghcr.io/llacskon33/android-cloud-emulator:latest
```

## Configuration

| Variable / build arg | Default | Description |
|---|---|---|
| `VNC_PASSWORD` | random | VNC / noVNC password |
| `EMULATOR_RAM` | 4096 | Emulator RAM (MB) |
| `EMULATOR_CORES` | 4 | Emulator CPU cores |
| `SCREEN_RESOLUTION` | 1080x1920x24 | Virtual display |
| `ANDROID_API` (build arg) | 34 | Android API level |
| `SYSTEM_IMAGE_TAG` (build arg) | google_apis | System image flavor |

Ports: `6080` noVNC, `5900` VNC, `5555` adb. Ports are bound to localhost in `docker-compose.yml`.
CPU/memory limits are set under `deploy.resources.limits`.

## Scripts (`scripts/`)

- `start-emulator.sh` – container entrypoint (creates AVD, starts services)
- `monitor-resources.sh [interval] [count]` – CPU/RAM/disk/emulator status:
  `docker exec android-emulator monitor-resources.sh 5 1` (scripts are on `PATH`)
- `backup-data.sh [backup|restore <file>]` – archive `/data` into `/backups` (keeps `RETENTION`, default 5)
- `install.sh` – host setup on Ubuntu/Debian (Docker, KVM check, `docker compose up`); run with sudo

## Cloud deployment

KVM needs hardware virtualization, so choose VMs with nested virtualization or bare metal.

- **GCP**: `gcloud compute instances create android --machine-type=n2-standard-8 --enable-nested-virtualization --image-family=ubuntu-2204-lts --image-project=ubuntu-os-cloud --min-cpu-platform="Intel Haswell"`, then SSH and run `sudo scripts/install.sh`.
- **AWS**: use a `*.metal` instance (e.g. `c5.metal`, `m5zn.metal`); nested virtualization is not available on standard EC2 types (new 8th-gen Intel families support it).
- **Azure**: use Dv3/Ev3/Dsv5 or newer series, which support nested virtualization.

**Security**: don't expose 6080/5900 publicly. Use an SSH tunnel (`ssh -L 6080:localhost:6080 user@host`) or a TLS reverse proxy (Caddy/nginx) plus firewall rules. Always set a strong `VNC_PASSWORD`. The container runs as a non-root user.

## Performance tips

- Ensure `/dev/kvm` is mapped (`kvm-ok` on host); without it the emulator is extremely slow.
- Give 4+ cores and 6–8 GB RAM; keep `EMULATOR_RAM` below the container limit.
- Use an SSD-backed volume for `/data`.
- Lower `SCREEN_RESOLUTION` for slow networks.

## Troubleshooting

- **"/dev/kvm not accessible"**: pass `--device /dev/kvm`; set `KVM_GID` in `.env` to the host's `kvm` group id (`getent group kvm`).
- **Black screen in noVNC**: wait for boot (`docker logs -f android-emulator`).
- **Out-of-memory / killed**: raise container memory limit or lower `EMULATOR_RAM`.
- **adb**: `adb connect localhost:5555`.

## CI/CD

`.github/workflows/docker-publish.yml` builds the image on every push/PR and pushes to GitHub Container Registry (`ghcr.io/<owner>/android-cloud-emulator`) on `main` and `v*` tags.

## License

MIT

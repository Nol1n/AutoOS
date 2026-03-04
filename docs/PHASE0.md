# PHASE 0 — Préparation

0.1 Architecture (textuel)

- Host OS: Ubuntu LTS (24.04) avec KDE Plasma (Kubuntu base)
- OpenClaw daemon: systemd service `openclawd` (Unix socket + HTTP localhost)
- Popup UI: Qt/QML app `openclaw-shell` (hotkey global)
- VM host: libvirt/QEMU (OVMF UEFI), swtpm, virtio drivers, virtiofs
- Windows agent: service inside VM, WebSocket JSON-RPC
- Registry: FastAPI service serving `/index.json` and plugin artifacts, signed with Ed25519/minisign

0.2 Arborescence monorepo (initial)

- `README.md` : overview
- `LICENSE` : license
- `Makefile` : targets `bootstrap`, `devshell`, `ci-check`
- `tools/bootstrap.sh` : bootstrap host dev env
- `tools/devshell/` : Dockerfile + entrypoint pour dev shell
- `.github/workflows/ci.yml` : CI minimal
- `docs/PHASE0.md`, `docs/PHASE1.md`
- `packages/` : .deb packaging (future)
- `openclaw/` : daemon source (future)
- `shell/` : Qt/QML popup app (future)
- `windows/` : windows agent + provisioning scripts
- `registry/` : FastAPI registry

0.3 Conventions (essentielles)

- Versioning: semver `MAJOR.MINOR.PATCH` for packages and plugins
- Services: systemd names `openclawd.service`, `openclaw-shell.service`, `openclaw-registry.service`
- Paths:
  - Config: `/etc/openclaw/` (YAML)
  - Data: `/var/lib/openclaw/`
  - Logs: `journalctl -u <service>` + `/var/log/openclaw/` for artifacts
- Ports: registry default `127.0.0.1:8080` (configurable)
- Signing: `minisign` / Ed25519 for index and artifacts

0.4 Plan d'exécution (phases)

- Phase 1: Monorepo & outillage (this run) — 3 points
- Phase 2: Assistant MVP — 8 points (depends on 1)
- Phase 3: VM Windows MVP — 8 points (depends on 1)
- Phase 4: Bridge Linux↔Windows — 5 points
- Phase 5: Plugins & registry — 8 points
- Phase 6: Build ISO & release — 6 points

Dépendances: 1 → 2 & 3 → 4 → 5 → 6

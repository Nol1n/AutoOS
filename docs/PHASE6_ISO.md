# PHASE 6 — Build ISO & Custom Installer

Objectif: produire une image ISO Ubuntu Desktop (KDE) pré-configurée pour OpenClaw Desktop.

Stratégie (MVP):
- Méthode interactive avec Cubic (recommandée pour MVP rapide)
- Méthode non-interactive (live-build / debootstrap) pour CI/automatisation

6.1 Étapes générales (petites étapes exécutable):

6.1.1 Préparer le dossier `iso/` avec:
- `iso/pool/` : paquets `.deb` à injecter
- `iso/firstboot/` : scripts à exécuter au premier démarrage
- `iso/autoinstall/` : `user-data` + `meta-data` pour autoinstall

Fichiers/commandes exacts:

- mkdir -p iso/pool iso/firstboot iso/autoinstall

Résultat attendu: arborescence prête
Vérifications: `ls -R iso/` montre les dossiers
Rollback: rm -rf iso/

6.1.2 Préparer `user-data` (autoinstall) — template minimal

Fichier: `iso/autoinstall/user-data` (exemple fourni). Il installe un utilisateur, lance `late-commands` pour copier les scripts `firstboot` dans l'image target.

Commandes: copier `iso/autoinstall/*` dans la racine de l'ISO lors du build (voir `tools/os/build-iso.sh`).

Vérifications: valider YAML (`cloud-init` validator on Ubuntu) ou test via VM boot
Rollback: modifier ou supprimer `user-data` avant rebuild

6.1.3 Préparer scripts first-boot

Fichier: `iso/firstboot/99-openclaw-install.sh` (exécutable)
Objectif: installer `/opt/openclaw/*.deb`, créer config `/etc/openclaw/config.yaml`, activer `openclawd` services, initialiser registry local si demandé.

Commandes exactes (dans le script):

```bash
#!/bin/bash
set -e
dpkg -i /opt/openclaw/*.deb || apt-get -f install -y
systemctl enable --now openclawd.service || true
systemctl enable --now openclaw-shell.service || true
```

Vérification: après premier boot, `systemctl status openclawd` actif; `/var/log/openclaw/` présent
Rollback: fournir `firstboot/rollback.sh` pour désinstaller paquets et désactiver services

6.1.4 Méthode interactive (Cubic) — étapes rapides

Fichiers/commands:

- Install Cubic on Ubuntu host: `sudo apt-add-repository ppa:cubic-wizard/release && sudo apt update && sudo apt install cubic`
- Run `cubic` and open original Ubuntu Desktop ISO
- In Cubic terminal inside chroot:
  - Copy `.deb` into `/opt/openclaw/` and `cp -r /workspace/iso/firstboot /target/etc/openclaw-firstboot` (see Cubic GUI)
  - Add `late-command` or `curtin` config to run firstboot scripts (copy to `/target`)
  - Install desired packages: `dpkg -i /opt/openclaw/*.deb` or add to apt repository inside image
- Generate ISO

Expected: ISO that when installed runs autoinstall and firstboot scripts to set up OpenClaw

6.1.5 Méthode non-interactive (live-build outline)

- Use `live-build` to create LiveCD; steps:
  - `lb config --distribution jammy --archive-areas "main universe multiverse" --apt-indices` (adjust for 24.04)
  - Place `.deb` in `config/packages.chroot/` or use `config/includes.chroot/opt/openclaw/`
  - Add `config/includes.installer/` with autoinstall files
  - `lb build`

6.2 Fichiers ajoutés dans ce repo (squelettes)
- `tools/os/build-iso.sh` — script d'aide pour préparer les artefacts et lancer Cubic ou live-build
- `iso/autoinstall/user-data` — template autoinstall
- `iso/autoinstall/meta-data` — minimal
- `iso/firstboot/99-openclaw-install.sh` — script firstboot

6.3 Tests et vérifications
- Test local: utiliser `virt-install` pour créer VM et booter ISO; vérifier `systemctl status openclawd` après install.
- Commandes de test:

```bash
virt-install --name ocd-test --ram 4096 --vcpus 2 --os-variant ubuntu24.04 \
  --disk size=30 --graphics spice --cdrom ./custom-ubuntu-ocd.iso --network network=default

# After install and first-boot, inside host
virsh list --all
virsh console ocd-test
```

Rollback plan
- Keep original Ubuntu ISO unchanged. Build artifacts in `dist/iso/` and remove on failure.

6.4 Remarques de sécurité et policy
- Signer les paquets `.deb` et inclure clé dans l'image pour vérification
- Ajouter fingerprint de signature et vérifier lors du first-boot

---

Prochaine action: j'ajoute les squelettes mentionnés (`tools/os/build-iso.sh`, `iso/autoinstall/*`, `iso/firstboot/*`) dans le repo afin que tu puisses lancer Cubic ou la build non-interactive.

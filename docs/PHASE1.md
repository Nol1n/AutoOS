# PHASE 1 — Monorepo + Outillage

1.1 Initialiser le repo

Objectif:
- Créer les fichiers de base: README, LICENSE, .editorconfig, .gitignore, .pre-commit-config.yaml

Commandes exactes:

```bash
git init
git add README.md LICENSE .editorconfig .gitignore .pre-commit-config.yaml Makefile
git commit -m "chore: init repo skeleton (PHASE1)"
```

Résultat attendu:
- Commit présent avec fichiers listés

Vérifications:
- `git status --porcelain` doit être vide
- `git log -1 --pretty=%B` contient "init repo skeleton"

Rollback:
- `git reset --hard HEAD~1` (si vous voulez supprimer le commit)

1.2 Ajouter `Makefile` et `./tools/bootstrap.sh`

Objectif:
- Fournir commandes `make bootstrap` et `make ci-check` pour environment reproducible

Commandes exactes (exécution):

```bash
chmod +x ./tools/bootstrap.sh
make bootstrap
```

Résultat attendu:
- Virtualenv `.venv` créé
- paquets système listés installés (selon droits sudo)

Vérifications:
- `.venv/bin/activate` existe
- `which qemu-system-x86_64` retourne un chemin

Rollback:
- Supprimer `.venv` et annuler paquets installés avec apt (manuel)

1.3 Ajouter `tools/devshell/` pour reproduire l'environnement

Objectif:
- Fournir un Dockerfile pour devshell

Commandes exactes:

```bash
docker build -t ocd-devshell ./tools/devshell
```

Résultat attendu:
- Image `ocd-devshell` construite

Vérifications:
- `docker images | grep ocd-devshell`

Rollback:
- `docker rmi ocd-devshell`

1.4 Ajouter GitHub Actions minimal

Objectif:
- Ajouter `.github/workflows/ci.yml` pour exécuter `make ci-check`

Commandes exactes:

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add minimal CI workflow"
```

Résultat attendu:
- Workflow présent dans repo; déclenché sur push

Vérifications:
- `gh workflow list` (si `gh` installé) ou regarder l'onglet Actions

Rollback:
- Supprimer le fichier `.github/workflows/ci.yml` et commit

Cheat sheet debug (PHASE1)

- Voir `./tools/bootstrap.sh` pour packages.
- Logs système: `journalctl -xe` si problème de services futurs.

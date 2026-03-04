Cheat sheet — PHASE1

- Bootstrap host (Ubuntu 24.04):

```bash
./tools/bootstrap.sh
```

- Build devshell Docker image:

```bash
docker build -t ocd-devshell ./tools/devshell
```

- Run openclawd stub locally:

```bash
python3 -m openclaw.daemon --port 8765
curl -X POST -d 'hello' http://127.0.0.1:8765/
```

- Run registry stub (for development):

```bash
pip install -r registry/requirements.txt
uvicorn registry.main:app --reload --host 127.0.0.1 --port 8080
```

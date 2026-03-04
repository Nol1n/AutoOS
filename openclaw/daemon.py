#!/usr/bin/env python3
"""
OpenClaw daemon (PHASE2 MVP)

- Listens on HTTP localhost (default 8765) for JSON commands
- Also listens on Unix domain socket `/run/openclaw/openclaw.sock` for newline-delimited JSON
- Supports actions: create_folder, move_file, launch_app
- Config: `/etc/openclaw/config.yaml` (template in repo)
"""
import argparse
import json
import logging
import os
import socket
import threading
import http.server
from http import HTTPStatus
from pathlib import Path
from typing import Dict, Any

import yaml

from openclaw import actions

LOG = logging.getLogger("openclawd")
logging.basicConfig(level=logging.INFO, format='%(message)s')


DEFAULT_CONFIG = {
    "http_port": 8765,
    "unix_socket": "/run/openclaw/openclaw.sock",
    "log_dir": "/var/log/openclaw",
}


def load_config(path: str = "/etc/openclaw/config.yaml") -> Dict[str, Any]:
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as fh:
            return yaml.safe_load(fh) or DEFAULT_CONFIG
    return DEFAULT_CONFIG


class JSONHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("content-length", 0))
        body = self.rfile.read(length).decode("utf-8")
        try:
            payload = json.loads(body)
        except Exception:
            self.send_response(HTTPStatus.BAD_REQUEST)
            self.end_headers()
            return
        LOG.info(json.dumps({"event": "command_received", "payload": payload}))
        resp = handle_command(payload)
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(resp).encode("utf-8"))


def handle_command(payload: Dict[str, Any]) -> Dict[str, Any]:
    try:
        cmd = payload.get("action")
        args = payload.get("args", {})
        if cmd == "create_folder":
            path = args.get("path")
            actions.create_folder(path)
            return {"status": "ok"}
        if cmd == "move_file":
            src = args.get("src")
            dst = args.get("dst")
            actions.move_file(src, dst)
            return {"status": "ok"}
        if cmd == "launch_app":
            cmdline = args.get("cmd")
            actions.launch_app(cmdline)
            return {"status": "ok"}
        return {"status": "error", "error": "unknown_action"}
    except Exception as e:
        LOG.error(json.dumps({"event": "command_error", "error": str(e)}))
        return {"status": "error", "error": str(e)}


def unix_socket_server(path: str):
    # ensure directory
    p = Path(path)
    if p.exists():
        try:
            p.unlink()
        except Exception:
            pass
    p.parent.mkdir(parents=True, exist_ok=True)
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.bind(path)
    sock.listen(1)
    LOG.info(json.dumps({"event": "unix_socket_listening", "path": path}))
    try:
        while True:
            conn, _ = sock.accept()
            threading.Thread(target=handle_unix_conn, args=(conn,), daemon=True).start()
    finally:
        sock.close()


def handle_unix_conn(conn: socket.socket):
    with conn:
        buf = b""
        while True:
            data = conn.recv(4096)
            if not data:
                break
            buf += data
            while b"\n" in buf:
                line, buf = buf.split(b"\n", 1)
                try:
                    payload = json.loads(line.decode("utf-8"))
                    LOG.info(json.dumps({"event": "uds_command", "payload": payload}))
                    resp = handle_command(payload)
                    conn.send((json.dumps(resp) + "\n").encode("utf-8"))
                except Exception as e:
                    conn.send((json.dumps({"status": "error", "error": str(e)}) + "\n").encode("utf-8"))


def run_http(port: int):
    server = http.server.ThreadingHTTPServer(("127.0.0.1", port), JSONHandler)
    LOG.info(json.dumps({"event": "http_listening", "port": port}))
    try:
        server.serve_forever()
    finally:
        server.server_close()


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--config", default="/etc/openclaw/config.yaml")
    args = p.parse_args()
    cfg = load_config(args.config)
    http_port = int(cfg.get("http_port", 8765))
    uds_path = cfg.get("unix_socket", "/run/openclaw/openclaw.sock")

    # Start UDS server thread
    t = threading.Thread(target=unix_socket_server, args=(uds_path,), daemon=True)
    t.start()

    # Start HTTP server (blocking)
    run_http(http_port)


if __name__ == "__main__":
    main()

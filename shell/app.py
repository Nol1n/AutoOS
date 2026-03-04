#!/usr/bin/env python3
"""
Minimal Qt/QML shell for OpenClaw (PHASE2 MVP).

Functionality:
- Simple QML window with a text input and send button
- Calls local HTTP API on 127.0.0.1:8765 to send commands

Notes:
- Global hotkey integration for KDE will be added later; current MVP uses window-level shortcut Ctrl+Space to focus.
"""
import sys
import json
import requests
from PySide6.QtCore import QObject, Slot
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine


class Backend(QObject):
    def __init__(self):
        super().__init__()

    @Slot(str)
    def sendText(self, text: str):
        payload = {"action": "launch_app", "args": {"cmd": text}}
        try:
            r = requests.post("http://127.0.0.1:8765/", json=payload, timeout=2)
            print("sent", r.status_code, r.text)
        except Exception as e:
            print("error sending", e)


def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)
    engine.load("./shell/main.qml")
    if not engine.rootObjects():
        sys.exit(1)
    sys.exit(app.exec())


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
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
    engine.load("/usr/share/openclaw/shell/main.qml")
    if not engine.rootObjects():
        sys.exit(1)
    sys.exit(app.exec())


if __name__ == "__main__":
    main()

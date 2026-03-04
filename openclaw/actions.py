"""Helper actions executed by openclawd (safe, minimal implementations).
"""
import os
import shutil
import subprocess


def create_folder(path: str):
    if not path:
        raise ValueError("path required")
    os.makedirs(path, exist_ok=True)


def move_file(src: str, dst: str):
    if not src or not dst:
        raise ValueError("src and dst required")
    shutil.move(src, dst)


def launch_app(cmd: str):
    if not cmd:
        raise ValueError("cmd required")
    # Best-effort: run detached
    subprocess.Popen(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

import importlib.resources
import os
import subprocess
import sys


def run():
    if os.name != "nt":
        sys.exit("copilot-ollama-windows is only supported on Windows.")

    try:
        with importlib.resources.path("copilot_ollama_windows", "run.ps1") as ps1_path:
            args = ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(ps1_path), *sys.argv[1:]]
            ret = subprocess.run(args)
            sys.exit(ret.returncode)
    except FileNotFoundError:
        sys.exit("Could not locate PowerShell start script in package")

import importlib.resources
import os
import subprocess
import sys


def run():
    if os.name != "nt":
        sys.exit("copilot-ollama-windows is only supported on Windows.")
    if len(sys.argv) < 1:
        sys.exit("Error: no config file provided")

    try:
        with importlib.resources.path("copilot_ollama_windows", "run.ps1") as ps1_path:
            ps_command = f'& "{ps1_path}" "{sys.argv[1]}"'

            args = ["powershell", "-ExecutionPolicy", "Bypass", "-Command", ps_command]
            ret = subprocess.run(args)
            sys.exit(ret.returncode)
    except FileNotFoundError:
        sys.exit("Could not locate PowerShell start script in package")

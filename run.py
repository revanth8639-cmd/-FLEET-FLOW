"""Build and run FleetFlow as one integrated web application."""

from pathlib import Path
import os
import shutil
import subprocess
import sys


project_root = Path(__file__).resolve().parent
frontend_dir = project_root / "frontend"
backend_dir = project_root / "backend"
npm_command = shutil.which("npm.cmd") or shutil.which("npm")

if not npm_command:
    raise SystemExit("Node.js/npm is required. Install Node.js, then run this command again.")

subprocess.run([npm_command, "run", "build"], cwd=frontend_dir, check=True)
os.chdir(backend_dir)
subprocess.run([sys.executable, "-m", "alembic", "upgrade", "head"], check=True)
os.execv(
    sys.executable,
    [sys.executable, "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", "8000"],
)

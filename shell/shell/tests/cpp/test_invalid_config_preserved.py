#!/usr/bin/env python3
"""Verify that a settings write does not replace malformed config.json."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--binary", type=Path, required=True)
parser.add_argument("--qml-test", type=Path, required=True)
args = parser.parse_args()

with tempfile.TemporaryDirectory(prefix="sirca-invalid-config-") as temporary:
    root = Path(temporary)
    config_home = root / "config"
    config_file = config_home / "sirca-shell" / "config.json"
    config_file.parent.mkdir(parents=True)
    original = b'{"broken":\n'
    config_file.write_bytes(original)
    env = dict(os.environ)
    env.update({
        "XDG_CONFIG_HOME": str(config_home),
        "XDG_DATA_HOME": str(root / "data"),
        "XDG_CACHE_HOME": str(root / "cache"),
        "QT_QPA_PLATFORM": "offscreen",
        "QT_QUICK_BACKEND": "software",
    })
    command = [
        "dbus-run-session", "--", "timeout", "25s", str(args.binary.resolve()),
        "--qml-test", str(args.qml_test.resolve()),
    ]
    result = subprocess.run(command, env=env, capture_output=True, text=True)
    if result.returncode != 0:
        raise SystemExit(f"shell QML test failed ({result.returncode}):\n{result.stdout}\n{result.stderr}")
    if config_file.read_bytes() != original:
        raise SystemExit("malformed config.json was modified")
    if "refusing to replace invalid configuration JSON" not in result.stderr:
        raise SystemExit("the malformed config guard did not report refusal")

print("PASS: malformed config.json preserved")

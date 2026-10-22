#!/bin/sh

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMPONENTS_DIR="$(dirname "$SCRIPT_DIR")"

cd $COMPONENTS_DIR
cmake -S . -B _build -Wno-dev
cmake --build _build -j

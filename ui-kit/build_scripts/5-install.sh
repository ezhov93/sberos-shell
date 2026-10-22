#!/bin/sh

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMPONENTS_DIR="$(dirname "$SCRIPT_DIR")"

cd $COMPONENTS_DIR
sudo cmake --install _build

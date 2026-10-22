#!/bin/bash

COMPONENTS_DIR="/usr/share/SberComponents"

sudo mkdir -p "$COMPONENTS_DIR"
sudo cp -r "theme" "$COMPONENTS_DIR"
sudo chmod -R 755 "$COMPONENTS_DIR"

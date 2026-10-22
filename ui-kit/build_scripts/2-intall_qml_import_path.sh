#!/bin/sh

PATH_VARIABLE="QML_IMPORT_PATH"
if [[ "${!PATH_VARIABLE@a}" == *x* ]]; then
    echo "QML_IMPORT_PATH is already setted"
else
    SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    PLUGINS_DIR="$(dirname "$SCRIPT_DIR")/_output"
    mkdir -p "$PLUGINS_DIR"

    sudo echo "$PATH_VARIABLE=\"$PLUGINS_DIR\"" >> /etc/environment
    
    echo "environment variable QML_IMPORT_PATH setted"
    echo "reboot your system (or relogin)"
fi


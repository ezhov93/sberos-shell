#!/bin/sh

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMPONENTS_DIR="$(dirname "$SCRIPT_DIR")"

if [ -d "$COMPONENTS_DIR/../theme/" ]; then
    (cd $COMPONENTS_DIR/scripts/generate && python3 generate.py)
    sudo chmod -R 777 $COMPONENTS_DIR
else
    echo "plasma library does not exists or not on develop branch"
fi



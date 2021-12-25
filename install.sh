#! /usr/bin/env bash

cd "$(dirname $0)"

if command -v rsync > /dev/null; then
    rsync -a src/ "$HOME/"
else
    echo "Please install rsync and start over"
fi

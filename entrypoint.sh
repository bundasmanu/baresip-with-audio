#!/usr/bin/env bash
set -e

if [ "$1" = 'baresip' ]; then
    /usr/bin/baresip -f "/root/.baresip"
else
    exec "$@"
fi

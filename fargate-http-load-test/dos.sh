#!/usr/bin/env sh

DEFAULT_TARGET="http://localhost:8080/"
TARGET="${1:-$DEFAULT_TARGET}"
while true; do /usr/bin/ab -n 1000000 -c 1000 $TARGET; done
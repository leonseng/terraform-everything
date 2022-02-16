#!/usr/bin/env sh

DEFAULT_TARGET="http://localhost:8080/"
DEFAULT_CONCURRENCY="100"

TARGET="${1:-$DEFAULT_TARGET}"
CONCURRENCY="${1:-$DEFAULT_CONCURRENCY}"

while true; do /usr/bin/ab -n 1000000 -c $CONCURRENCY $TARGET; done
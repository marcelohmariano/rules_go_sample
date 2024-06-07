#!/usr/bin/env bash
set -euo pipefail

program="$1"

got="$("$program")"
want="Hello, world!"

if [[ "$got" != "$want" ]]; then
    echo -e "got: ${got}\nwant: ${want}" >&2
    exit 1
fi
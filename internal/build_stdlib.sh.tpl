#!/usr/bin/env bash
set -euo pipefail

cd "$(realpath .)"

export GOCACHE="${PWD}/{cache}"

go list -export \
    -f '{{if .Export -}} packagefile {{.ImportPath}}={{.Export}} {{- end}}' \
    std | \
sed -r "s,=${PWD}/,=," > '{importcfg}'
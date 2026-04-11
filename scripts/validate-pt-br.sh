#!/usr/bin/env bash

set -euo pipefail

for file in src-pt-br/*.md; do
    echo "Checking references in $file"
    cargo run --quiet --bin link2print < "$file" > /dev/null
done

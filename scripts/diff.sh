#!/bin/bash

git fetch upstream

echo "📂 Arquivos alterados:"
git diff upstream/main --name-only | grep "^src/.*\.md" || true

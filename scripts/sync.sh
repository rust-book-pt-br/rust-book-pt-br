#!/bin/bash
set -e

echo "🔄 Sync com upstream..."

git fetch upstream
git checkout main
git merge upstream/main --no-edit

echo "✅ Sync concluído"

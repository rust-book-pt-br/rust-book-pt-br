#!/usr/bin/env bash

set -euo pipefail

export MDBOOK_BOOK__TITLE="A Linguagem de Programação Rust (PT-BR)"
export MDBOOK_BOOK__LANGUAGE="pt-BR"
export MDBOOK_BOOK__SRC="src-pt-br"
export MDBOOK_BUILD__BUILD_DIR="book-pt-br"

mdbook build

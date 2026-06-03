#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "Witaj w instalatorze .dotfiles dla systemu macOS!"
if ! confirm_continue "Czy chcesz kontynuowac? (y/n)"; then
  echo ""
  echo "Instalacja anulowana. Do zobaczenia!"
  exit 1
fi

install_macos
install_base_dotfiles
install_vscode

echo ""
echo "Instalacja zakonczona! Do zobaczenia!"

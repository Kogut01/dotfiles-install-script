#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$SCRIPT_DIR/install"
TARGET=""

# Przekazujemy katalog repozytorium do skryptow podrzednych.
export DOTFILES="$SCRIPT_DIR"

run_installer() {
  local installer_path="$1"

  if [ ! -f "$installer_path" ]; then
    echo "Brakuje skryptu instalatora: $installer_path"
    exit 1
  fi

  bash "$installer_path"
}

select_linux_target() {
  local choice

  echo "Wykryto system Linux. Wybierz wariant instalacji:"
  echo "1) linux (bez desktop)"
  echo "2) linux-desktop (z desktop)"
  read -r choice

  case "$choice" in
    1|linux)
      TARGET="linux"
      ;;
    2|linux-desktop)
      TARGET="linux-desktop"
      ;;
    *)
      echo "Nieznany wybor: $choice"
      exit 1
      ;;
  esac
}

select_unknown_target() {
  local choice

  echo "Nie rozpoznano systemu. Wybierz wariant instalacji:"
  echo "1) macos"
  echo "2) linux"
  echo "3) linux-desktop"
  read -r choice

  case "$choice" in
    1|macos)
      TARGET="macos"
      ;;
    2|linux)
      TARGET="linux"
      ;;
    3|linux-desktop)
      TARGET="linux-desktop"
      ;;
    *)
      echo "Nieznany wybor: $choice"
      exit 1
      ;;
  esac
}

detect_target_from_os() {
  local os_name
  os_name="$(uname -s)"

  case "$os_name" in
    Darwin)
      TARGET="macos"
      ;;
    Linux)
      select_linux_target
      ;;
    *)
      echo "Wykryty system: $os_name"
      select_unknown_target
      ;;
  esac
}

run_selected_target() {
  case "$TARGET" in
    macos)
      run_installer "$INSTALLER_DIR/macos.sh"
      ;;
    linux)
      run_installer "$INSTALLER_DIR/linux.sh"
      ;;
    linux-desktop)
      run_installer "$INSTALLER_DIR/linux-desktop.sh"
      ;;
    *)
      echo "Nie udalo sie wybrac poprawnego wariantu instalacji."
      exit 1
      ;;
  esac
}

if [ -n "${1:-}" ]; then
  echo "Tryb z argumentem jest wylaczony. Uruchom po prostu: ./install.sh"
fi

detect_target_from_os

run_selected_target

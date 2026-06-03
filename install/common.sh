#!/usr/bin/env bash
DOTFILES="${DOTFILES:-$HOME/.dotfiles}"


# Linkowanie plikow z katalogu src do odpowiednich miejsc w systemie.
link_file() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"

  echo "Linked $src -> $dest"
}


# Wspolna walidacja instalacji narzedzia po nazwie polecenia.
check_tool_installed() {
  local tool_name="$1"
  local command_name="$2"

  command_exists() {
    command -v "$1" >/dev/null 2>&1
  }

  if command_exists "$command_name"; then
    echo "$tool_name jest juz zainstalowany"
    return 0
  fi

  echo "$tool_name nie jest zainstalowany"
  return 1
}


# Funkcja do potwierdzania kontynuacji instalacji.
confirm_continue() {
  local question="$1"

  echo "$question"
  read -r response
  [ "$response" = "y" ]
}


# Sprawdzenie, czy polecenia są dostepne w systemie.
check_bat() {
  check_tool_installed "bat" "bat"
}


check_brew() {
  check_tool_installed "Homebrew" "brew"
}


check_btop() {
  check_tool_installed "btop" "btop"
}


check_fastfetch() {
  check_tool_installed "fastfetch" "fastfetch"
}


check_ghostty() {
  check_tool_installed "ghostty" "ghostty"
}


check_git() {
  check_tool_installed "git" "git"
}


check_neovim() {
  check_tool_installed "neovim" "nvim"
}


check_zsh() {
  check_tool_installed "zsh" "zsh"
}


check_vscode() {
  check_tool_installed "VS Code" "code"
}


check_hyprland() {
  check_tool_installed "hyprland" "hyprctl"
}


check_hyprpanel() {
  check_tool_installed "hyprpanel" "hyprpanel"
}


check_rofi() {
  check_tool_installed "rofi" "rofi"
}


check_oh_my_zsh() {
  check_tool_installed "Oh My Zsh" "upgrade_oh_my_zsh"
}


check_oh_my_posh() {
  check_tool_installed "Oh My Posh" "oh-my-posh"
}


# Instalacja pluginow do Zsh.
install_zsh_plugins() {
  local zsh_custom_plugins="$HOME/.oh-my-zsh/custom/plugins"

  mkdir -p "$zsh_custom_plugins"

  clone_plugin() {
    local repo_url="$1"
    local plugin_name="$2"
    local plugin_path="$zsh_custom_plugins/$plugin_name"

    if [ -d "$plugin_path/.git" ]; then
      echo "Plugin jest juz zainstalowany: $plugin_name"
      return
    fi

    if [ -d "$plugin_path" ]; then
      rm -rf "$plugin_path"
    fi

    git clone --depth 1 "$repo_url" "$plugin_path"
    echo "Zainstalowano plugin: $plugin_name"
  }

  clone_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "zsh-autosuggestions"
  clone_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting"
  clone_plugin "https://github.com/marlonrichert/zsh-autocomplete.git" "zsh-autocomplete"
}


# Instalacja podstawowych dotfiles, wspolna dla wszystkich systemow.
install_base_dotfiles() {
  check_bat || true
  check_btop || true
  check_fastfetch || true
  check_ghostty || true
  check_git || true
  check_neovim || true
  check_zsh || true
  check_oh_my_zsh || true
  check_oh_my_posh || true

  link_file "$DOTFILES/src/dot_bat/config" "$HOME/.config/bat/config"
  link_file "$DOTFILES/src/dot_btop/btop.conf" "$HOME/.config/btop/btop.conf"

  link_file "$DOTFILES/src/dot_fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  link_file "$DOTFILES/src/dot_fastfetch/rooster.txt" "$HOME/.config/fastfetch/rooster.txt"

  link_file "$DOTFILES/src/dot_ghostty/config" "$HOME/.config/ghostty/config"
  link_file "$DOTFILES/src/dot_ghostty/shaders/cursor.glsl" "$HOME/.config/ghostty/shaders/cursor.glsl"

  link_file "$DOTFILES/src/dot_git/ignore" "$HOME/.config/git/ignore"
  link_file "$DOTFILES/src/dot_git/.gitconfig" "$HOME/.gitconfig"

  link_file "$DOTFILES/src/dot_nvim/init.lua" "$HOME/.config/nvim/init.lua"
  link_file "$DOTFILES/src/dot_nvim/lua/plugins/background.lua" "$HOME/.config/nvim/lua/plugins/background.lua"
  link_file "$DOTFILES/src/dot_nvim/lua/config/lazy.lua" "$HOME/.config/nvim/lua/config/lazy.lua"
  link_file "$DOTFILES/src/dot_nvim/lua/config/kogut01.lua" "$HOME/.config/nvim/lua/config/kogut01.lua"

  link_file "$DOTFILES/src/dot_zsh/.zshrc" "$HOME/.zshrc"
  install_zsh_plugins
}


# Instalacja rozszerzen i ustawien VS Code.
install_vscode() {
  local settings_dest

  if [ "$(uname)" = "Darwin" ]; then
    settings_dest="$HOME/Library/Application Support/Code/User/settings.json"
  else
    settings_dest="$HOME/.config/Code/User/settings.json"
  fi

  check_vscode || true

  if command_exists code; then
    while read -r ext || [ -n "$ext" ]; do
      [ -n "$ext" ] && code --no-sandbox --force --install-extension "$ext"
      sleep 0.5
    done < "$DOTFILES/src/dot_vscode/extensions.txt"
  else
    echo "Polecenie 'code' nie jest dostepne, pomijam instalacje rozszerzen VS Code"
  fi

  link_file "$DOTFILES/src/dot_vscode/settings.json" "$settings_dest"
}


# Instalacja specyficznych dotfiles dla systemu macOS.
install_macos() {
  check_brew || true

  brew bundle --file="$DOTFILES/src/dot_brew/Brewfile"
}


# Instalacja specyficznych dotfiles dla systemu Linux z desktopem.
install_linux_desktop_dotfiles() {
  check_hyprland || true
  check_hyprpanel || true
  check_rofi || true

  link_file "$DOTFILES/src/dot_hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
  link_file "$DOTFILES/src/dot_hyprland/hyprland/00-base.conf" "$HOME/.config/hypr/hyprland/00-base.conf"
  link_file "$DOTFILES/src/dot_hyprland/hyprland/10-outputs.conf" "$HOME/.config/hypr/hyprland/10-outputs.conf"
  link_file "$DOTFILES/src/dot_hyprland/hyprland/20-inputs.conf" "$HOME/.config/hypr/hyprland/20-inputs.conf"
  link_file "$DOTFILES/src/dot_hyprland/hyprland/30-keybinds.conf" "$HOME/.config/hypr/hyprland/30-keybinds.conf"
  link_file "$DOTFILES/src/dot_hyprland/hyprland/40-windows.conf" "$HOME/.config/hypr/hyprland/40-windows.conf"
  link_file "$DOTFILES/src/dot_hyprland/hyprland/50-exec.conf" "$HOME/.config/hypr/hyprland/50-exec.conf"
  link_file "$DOTFILES/src/dot_hyprland/hyprland/60-ui.conf" "$HOME/.config/hypr/hyprland/60-ui.conf"

  link_file "$DOTFILES/src/dot_hyprpanel/config.json" "$HOME/.config/hyprpanel/config.json"
  link_file "$DOTFILES/src/dot_hyprpanel/modules.json" "$HOME/.config/hyprpanel/modules.json"
  link_file "$DOTFILES/src/dot_hyprpanel/modules.scss" "$HOME/.config/hyprpanel/modules.scss"

  link_file "$DOTFILES/src/dot_rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
  link_file "$DOTFILES/src/dot_rofi/theme.rasi" "$HOME/.config/rofi/theme.rasi"

  sudo cp "$DOTFILES/src/dot_greetd_regreet/config.toml" "/etc/greetd/config.toml"
  sudo cp "$DOTFILES/src/dot_greetd_regreet/hyprland.conf" "/etc/greetd/hyprland.conf"
  sudo cp "$DOTFILES/src/dot_greetd_regreet/regreet.css" "/etc/greetd/regreet.css"
  sudo cp "$DOTFILES/src/dot_greetd_regreet/regreet.toml" "/etc/greetd/regreet.toml"
  sudo cp "$DOTFILES/data/dot_wallpaper/wallpaper_dark.png" "/etc/greetd/greeter.png"

  sudo chmod 644 "/etc/greetd/config.toml"
  sudo chmod 644 "/etc/greetd/hyprland.conf"
  sudo chmod 644 "/etc/greetd/regreet.css"
  sudo chmod 644 "/etc/greetd/regreet.toml"
  sudo chmod 644 "/etc/greetd/greeter.png"
}
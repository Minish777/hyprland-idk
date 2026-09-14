#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  hyprland-idk installer — Arch/Arch-based (Hyprland + Noctalia)
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

log()   { echo -e "${CYAN}[*]${NC} $1"; }
ok()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[X]${NC} $1"; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/config"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}"

# ------------------------------------------------------------
#  Печатает false, если пакет не установлен (pacman/paru)
# ------------------------------------------------------------
is_installed() { pacman -Q "$1" >/dev/null 2>&1; }

install_pkgs() {
    local missing=()
    for pkg in "$@"; do
        is_installed "$pkg" || missing+=("$pkg")
    done
    ((${#missing[@]})) || return 0

    log "Установка: ${missing[*]}"
    if command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm "${missing[@]}"
    elif command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm "${missing[@]}"
    else
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi
}

# ------------------------------------------------------------
#  Основные зависимости
# ------------------------------------------------------------
check_root() { [[ $EUID -eq 0 ]] && err "Не запускай от root — скрипту нужен обычный пользователь с sudo."; }

install_deps() {
    log "Проверка AUR helper (paru/yay)..."
    if ! command -v paru >/dev/null 2>&1 && ! command -v yay >/dev/null 2>&1; then
        warn "paru/yay не найден. Ставлю paru..."
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/paru.git /tmp/paru-bin
        (cd /tmp/paru-bin && makepkg -si --noconfirm)
        rm -rf /tmp/paru-bin
    fi

    log "Установка зависимостей..."
    install_pkgs \
        hyprland hyprpicker noctalia-git \
        foot fish eza zoxide starship fastfetch \
        micro yazi bat broot btop cava lazygit \
        wl-clipboard cliphist gnome-keyring \
        zen-browser nautilus gnome-text-editor pwvucontrol \
        gammastep geoclue mpris-proxy hyprpicker \
        spicetify-cli \
        ttf-jetbrains-mono-nerd noto-fonts \
        bibata-cursor-theme \
        papirus-icon-theme

    log "Установка плагинов fish (fisher + tide)..."
    fish -c 'fisher install jorgebucaran/fisher' >/dev/null 2>&1 || true
    fish -c 'fisher install ilancosman/tide@v6' >/dev/null 2>&1 || true
}

# ------------------------------------------------------------
#  Копирование конфигов
# ------------------------------------------------------------
deploy_configs() {
    [[ -d "$CONFIG_DIR" ]] || err "Не найдена папка config/ в репо: $CONFIG_DIR"

    log "Копирование конфигов в $DEST..."
    local dirs=(btop cava fastfetch fish foot hypr micro noctalia spicetify wallust yazi)
    for d in "${dirs[@]}"; do
        if [[ -d "$CONFIG_DIR/$d" ]]; then
            mkdir -p "$DEST/$d"
            cp -r "$CONFIG_DIR/$d/." "$DEST/$d/"
            ok "→ $d"
        fi
    done

    # starship
    cp "$CONFIG_DIR/starship.toml" "$DEST/starship.toml"
    ok "→ starship.toml"

    # wallust: копируем темплейты и запускаем генерацию от текущих обоев
    if command -v wallust >/dev/null 2>&1 && [[ -f "$DEST/wallust/wallust.toml" ]]; then
        log "Генерация цветов wallust..."
        mkdir -p "$DEST/dunst" "$DEST/rofi"
        if command -v dunst >/dev/null 2>&1; then
            wallust run >/dev/null 2>&1 || true
        fi
    fi
}

# ------------------------------------------------------------
#  Обои
# ------------------------------------------------------------
deploy_wallpapers() {
    local wall_dir="$HOME/wallpapers"
    if [[ -d "$REPO_DIR/wallpapers" ]]; then
        log "Копирование обоев в $wall_dir..."
        mkdir -p "$wall_dir"
        cp -r "$REPO_DIR/wallpapers/." "$wall_dir/"
        ok "→ $wall_dir"
    fi
}

# ------------------------------------------------------------
#  Финал
# ------------------------------------------------------------
summary() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Готово! Перезапусти сессию:${NC}"
    echo
    echo -e "  ${CYAN}_exit${NC} в Hyprland, затем зайди заново."
    echo
    echo -e "  Konфиги:      $DEST"
    echo -e "  Обои:         $HOME/wallpapers"
    echo -e "  Плагины fish: fisher + tide@v6"
    echo -e "${GREEN}========================================${NC}"
}

# ------------------------------------------------------------
main() {
    check_root
    install_deps
    deploy_configs
    deploy_wallpapers
    summary
}

main "$@"
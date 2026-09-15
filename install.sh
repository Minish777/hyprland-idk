#!/usr/bin/env bash
# hyprland-idk installer — Arch/Arch-based
# Simple, safe install with good logging and clear errors

set -euo pipefail

# ===== CONFIG =====
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/config"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}"
WALL_DIR="$HOME/wallpapers"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/hyprland-idk-install-$(date +%Y%m%d-%H%M%S).log"
ERROR_LOG="/tmp/hyprland-idk-errors-$(date +%Y%m%d-%H%M%S).log"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

# ===== LOGGING UTILS =====
exec 3>&1 4>&2
exec 1> >(tee -a "$LOG_FILE") 2> >(tee -a "$ERROR_LOG" >&2)

log()   { echo -e "${CYAN}[*]${NC} $1"; }
ok()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[X]${NC} $1"; exit 1; }
info()  { echo -e "${BLUE}[i]${NC} $1"; }
step()  { echo -e "\n${CYAN}▶${NC} ${BOLD}$1${NC}"; }
prompt() { echo -ne "${YELLOW}[?]${NC} $1 " >&3; if [[ -t 0 ]]; then read -r ans; else read -r ans < /dev/tty 2>/dev/null || read -r ans; fi; echo "$ans"; }
die()   { echo -e "${RED}[X]${NC} $1" >&3; echo "See log: $LOG_FILE" >&3; exit 1; }

# Error trap with context
trap 'die "Error on line $LINENO in function ${FUNCNAME[1]:-main}. Check the log: $ERROR_LOG"' ERR

# ===== PROFILES (only full — everything else is covered) =====
# Noctalia covers: bar, launcher, notifications, wallpapers, lockscreen, control-center
# wallust/waybar/rofi are redundant
FULL_PKGS=(
    hyprland hyprpicker noctalia-git
    foot fish starship fastfetch
    eza zoxide micro yazi bat broot btop cava lazygit
    wl-clipboard cliphist gnome-keyring
    gammastep geoclue mpris-proxy
    zen-browser nautilus gnome-text-editor pwvucontrol
    ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme papirus-icon-theme
    spicetify-cli direnv
)

# ===== CHECKS =====
check_root() {
    if [[ $EUID -eq 0 ]]; then
        die "Do not run as root — run as a normal user with sudo."
    fi
}

check_distro() {
    step "Checking distro"
    if [[ ! -f /etc/os-release ]]; then
        die "/etc/os-release not found"
    fi
    . /etc/os-release
    local id="${ID:-}" id_like="${ID_LIKE:-}"
    case " $id $id_like " in
        *" arch "*|*" manjaro "*|*" endeavouros "*|*" garuda "*|*" cachyos "*|*" artix "*|*" archarm "*)
            ok "Detected: $PRETTY_NAME"
            ;;
        *)
            if command -v pacman >/dev/null 2>&1; then
                warn "Not in the list, but pacman is available: $PRETTY_NAME"
                die "Add your distro to check_distro() or use an Arch-based one"
            else
                die "Not Arch-based and no pacman: $PRETTY_NAME"
            fi
            ;;
    esac
}

check_sudo() {
    step "Checking sudo"
    sudo -n true 2>/dev/null || { log "sudo required — please authenticate"; sudo -v || die "Sudo is not configured"; }
    ok "Sudo OK"
}

# ===== INSTALL =====
ensure_aur_helper() {
    command -v paru >/dev/null 2>&1 && return 0
    command -v yay >/dev/null 2>&1 && return 0

    step "AUR helper not found — installing paru"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru-install
    (cd /tmp/paru-install && makepkg -si --noconfirm)
    rm -rf /tmp/paru-install
    ok "paru installed"
}

install_packages() {
    step "Installing packages"
    local missing=()
    for pkg in "${FULL_PKGS[@]}"; do
        pacman -Q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done

    ((${#missing[@]} == 0)) && { ok "All packages already installed"; return 0; }

    log "Installing (${#missing[@]}): ${missing[*]}"
    if command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm "${missing[@]}"
    elif command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm "${missing[@]}"
    else
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi
    ok "Packages installed"
}

# ===== OPTIONAL: asar (for Electron apps and Discord forks) =====
# Try several methods until one works
try_asar_method() {
    case "$1" in
        pacman)
            sudo pacman -S --needed --noconfirm asar
            ;;
        aur)
            if command -v paru >/dev/null 2>&1; then
                paru -S --noconfirm asar
            elif command -v yay >/dev/null 2>&1; then
                yay -S --noconfirm asar
            else
                return 1
            fi
            ;;
        npm_scoped)
            sudo npm install -g @electron/asar
            ;;
        npm_plain)
            sudo npm install -g asar
            ;;
        npm_user)
            npm install -g --prefix "$HOME/.local" @electron/asar asar || return 1
            [[ -x "$HOME/.local/bin/asar" ]] || return 1
            sudo ln -sf "$HOME/.local/bin/asar" /usr/local/bin/asar
            ;;
        *)
            return 1
            ;;
    esac
    command -v asar >/dev/null 2>&1
}

install_asar() {
    step "ASAR — utility for Electron (Discord forks etc.)"
    command -v asar >/dev/null 2>&1 && { ok "asar already installed: $(command -v asar)"; return 0; }

    info "asar is used to pack/unpack Electron apps: Vesktop, Discord forks, etc."
    prompt "Install asar? [y/N]: "
    if [[ ! $ans =~ ^[Yy]$ ]]; then
        info "Skipping asar"
        return 0
    fi

    local methods=(pacman aur npm_scoped npm_plain npm_user)
    local tried=()
    for m in "${methods[@]}"; do
        log "Trying method: $m"
        if try_asar_method "$m"; then
            ok "asar installed ($m): $(command -v asar)"
            return 0
        fi
        tried+=("$m")
    done

    err "asar failed to install. Tried: ${tried[*]}. See log: $ERROR_LOG"
}

setup_fish() {
    step "Setting up Fish (fisher + tide@v6)"
    command -v fish >/dev/null 2>&1 || { warn "fish is not installed"; return 0; }
    fish -c 'fisher install jorgebucaran/fisher' >/dev/null 2>&1 || true
    fish -c 'fisher install ilancosman/tide@v6' >/dev/null 2>&1 || true
    ok "Fish plugins installed"
}

backup_configs() {
    step "Backing up old configs → $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    local count=0
    for d in btop cava fastfetch fish foot hypr micro noctalia spicetify wallust yazi; do
        [[ -d "$DEST/$d" ]] && { cp -r "$DEST/$d" "$BACKUP_DIR/" 2>/dev/null; ((count++)); }
    done
    [[ -f "$DEST/starship.toml" ]] && { cp "$DEST/starship.toml" "$BACKUP_DIR/"; ((count++)); }
    ((count > 0)) && ok "Backed up $count dir(s) to $BACKUP_DIR" || info "No configs to back up"
}

deploy_configs() {
    step "Copying configs to $DEST"
    [[ -d "$CONFIG_DIR" ]] || die "config/ dir not found in repo: $CONFIG_DIR"

    local dirs=(btop cava fastfetch fish foot hypr micro noctalia spicetify wallust yazi)
    for d in "${dirs[@]}"; do
        if [[ -d "$CONFIG_DIR/$d" ]]; then
            mkdir -p "$DEST/$d"
            cp -r "$CONFIG_DIR/$d/." "$DEST/$d/"
            ok "→ $d"
        else
            warn "Skipped: $CONFIG_DIR/$d not found"
        fi
    done

    cp "$CONFIG_DIR/starship.toml" "$DEST/starship.toml"
    ok "→ starship.toml"
}

deploy_wallpapers() {
    step "Copying wallpapers to $WALL_DIR"
    [[ -d "$REPO_DIR/wallpapers" ]] || { warn "wallpapers/ dir not found in repo"; return 0; }
    mkdir -p "$WALL_DIR"
    cp -r "$REPO_DIR/wallpapers/." "$WALL_DIR/"
    ok "→ $WALL_DIR"

    if command -v wallust >/dev/null 2>&1 && [[ -f "$DEST/wallust/wallust.toml" ]]; then
        log "Generating wallust colors..."
        mkdir -p "$DEST/dunst" "$DEST/rofi" 2>/dev/null
        wallust run "$WALL_DIR"/* 2>/dev/null | head -1 || true
        ok "Wallust colors generated"
    fi
}

post_install() {
    step "Post-install setup"

    # GTK cursor
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true

    # GTK theme
    command -v nwg-look >/dev/null 2>&1 && nwg-look -a >/dev/null 2>&1 || true

    # Shell to fish
    if [[ "$SHELL" != *"fish"* ]]; then
        log "Current shell: $SHELL"
        prompt "Switch shell to fish? [y/N]: "
        if [[ $ans =~ ^[Yy]$ ]]; then
            chsh -s "$(command -v fish)" && ok "Shell changed to fish"
        fi
    fi

    ok "Post-install finished"
}

health_check() {
    step "Health check"
    local issues=0

    for bin in hyprland foot fish starship fastfetch; do
        command -v "$bin" >/dev/null 2>&1 || { warn "Missing binary: $bin"; ((issues++)); }
    done

    for f in hypr/hyprland.lua fish/config.fish fastfetch/config.jsonc starship.toml; do
        [[ -f "$DEST/$f" ]] || { warn "Missing config: $f"; ((issues++)); }
    done

    [[ -d "$WALL_DIR" ]] || { warn "Wallpapers were not copied"; ((issues++)); }

    if ((issues == 0)); then
        ok "Health check: all good"
    else
        warn "Found $issues issue(s). See log: $LOG_FILE"
    fi
}

# ===== MAIN =====
header() {
    clear
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║       hyprland-idk installer — Arch/Arch-based           ║${NC}"
    echo -e "${BOLD}${CYAN}║           Hyprland + Noctalia V5 rice                    ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
}

main() {
    header
    echo -e "${BOLD}Installing full profile (Noctalia covers bar, launcher, wallpapers, lockscreen)${NC}"
    echo -e "Packages: ${#FULL_PKGS[@]} — only missing ones will be installed\n"
    prompt "Press Enter to continue or Ctrl+C to cancel..."

    check_root
    check_distro
    check_sudo

    ensure_aur_helper
    install_packages
    install_asar
    setup_fish
    backup_configs
    deploy_configs
    deploy_wallpapers
    post_install
    health_check

    echo -e "\n${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║                    INSTALLATION COMPLETE                  ║${NC}"
    echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "  Configs:    ${CYAN}$DEST${NC}"
    echo -e "  Wallpapers: ${CYAN}$WALL_DIR${NC}"
    echo -e "  Backup:     ${CYAN}$BACKUP_DIR${NC}"
    echo -e "  Log:        ${CYAN}$LOG_FILE${NC}"
    echo -e "  Errors:     ${CYAN}$ERROR_LOG${NC}"
    echo
    echo -e "  ${YELLOW}Next steps:${NC}"
    echo -e "  1. ${CYAN}_exit${NC} in Hyprland (or re-login)"
    echo -e "  2. ${CYAN}Super+A${NC} — terminal, ${CYAN}Super+R${NC} — launcher, ${CYAN}Super+/${NC} — cheatsheet"
    echo -e "  3. ${CYAN}Super+T${NC} — wallpapers, ${CYAN}Super+V${NC} — clipboard"
    echo -e "  4. ${CYAN}Super+Shift+R${NC} — restart Noctalia"
    echo -e "  5. ${CYAN}Super+Space${NC} — float window, ${CYAN}Super+mouse↑/↓${NC} — switch workspace"
    echo
    echo -e "  ${BLUE}If something broke:${NC}"
    echo -e "  • Logs: ${CYAN}$LOG_FILE${NC} and ${CYAN}$ERROR_LOG${NC}"
    echo -e "  • Backup: ${CYAN}$BACKUP_DIR${NC} — restore with: cp -r $BACKUP_DIR/* ~/.config/"
    echo -e "  • Issues: https://github.com/Minish777/hyprland-idk/issues"
    echo
}

main "$@"
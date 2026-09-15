#!/usr/bin/env bash
# hyprland-idk installer — Arch/Arch-based
# Простая, безопасная установка с хорошими логами и понятными ошибками

set -euo pipefail

# ===== КОНФИГУРАЦИЯ =====
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/config"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}"
WALL_DIR="$HOME/wallpapers"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/hyprland-idk-install-$(date +%Y%m%d-%H%M%S).log"
ERROR_LOG="/tmp/hyprland-idk-errors-$(date +%Y%m%d-%H%M%S).log"

# Цвета
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

# ===== УТИЛИТЫ ЛОГГИРОВАНИЯ =====
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

# Ловушка ошибок с контекстом
trap 'die "Ошибка на строке $LINENO в функции ${FUNCNAME[1]:-main}. Проверь лог: $ERROR_LOG"' ERR

# ===== ПРОФИЛИ (только full — всё остальное в minimal/standard не нужно) =====
# Noctalia покрывает: bar, launcher, notifications, wallpapers, lockscreen, control-center
# wallust/waybar/rofi — избыточны
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

# ===== ПРОВЕРКИ =====
check_root() {
    [[ $EUID -eq 0 ]] && die "Не запускай от root — скрипту нужен обычный пользователь с sudo."
}

check_distro() {
    step "Проверка дистрибутива"
    if [[ ! -f /etc/os-release ]]; then
        die "Не найден /etc/os-release"
    fi
    . /etc/os-release
    local id="${ID:-}" id_like="${ID_LIKE:-}"
    case " $id $id_like " in
        *" arch "*|*" manjaro "*|*" endeavouros "*|*" garuda "*|*" cachyos "*|*" artix "*|*" archarm "*)
            ok "Обнаружен: $PRETTY_NAME"
            ;;
        *)
            if command -v pacman >/dev/null 2>&1; then
                warn "Дистрибутив не в списке, но pacman есть: $PRETTY_NAME"
                die "Добавь свой дистрибутив в check_distro() или используй Arch-based"
            else
                die "Не Arch-based и нет pacman: $PRETTY_NAME"
            fi
            ;;
    esac
}

check_sudo() {
    step "Проверка sudo"
    sudo -n true 2>/dev/null || { log "Требуются права sudo..."; sudo -v || die "Sudo не настроен"; }
    ok "Sudo OK"
}

# ===== УСТАНОВКА =====
ensure_aur_helper() {
    command -v paru >/dev/null 2>&1 && return 0
    command -v yay >/dev/null 2>&1 && return 0

    step "AUR helper не найден — ставим paru"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru-install
    (cd /tmp/paru-install && makepkg -si --noconfirm)
    rm -rf /tmp/paru-install
    ok "paru установлен"
}

install_packages() {
    step "Установка пакетов"
    local missing=()
    for pkg in "${FULL_PKGS[@]}"; do
        pacman -Q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done

    ((${#missing[@]} == 0)) && { ok "Все пакеты уже установлены"; return 0; }

    log "К установке (${#missing[@]}): ${missing[*]}"
    if command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm "${missing[@]}"
    elif command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm "${missing[@]}"
    else
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi
    ok "Пакеты установлены"
}

setup_fish() {
    step "Настройка Fish (fisher + tide@v6)"
    command -v fish >/dev/null 2>&1 || { warn "fish не установлен"; return 0; }
    fish -c 'fisher install jorgebucaran/fisher' >/dev/null 2>&1 || true
    fish -c 'fisher install ilancosman/tide@v6' >/dev/null 2>&1 || true
    ok "Fish plugins установлены"
}

backup_configs() {
    step "Бэкап старых конфигов → $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    local count=0
    for d in btop cava fastfetch fish foot hypr micro noctalia spicetify wallust yazi; do
        [[ -d "$DEST/$d" ]] && { cp -r "$DEST/$d" "$BACKUP_DIR/" 2>/dev/null; ((count++)); }
    done
    [[ -f "$DEST/starship.toml" ]] && { cp "$DEST/starship.toml" "$BACKUP_DIR/"; ((count++)); }
    ((count > 0)) && ok "Забэкаплено $count папок: $BACKUP_DIR" || info "Нет конфигов для бэкапа"
}

deploy_configs() {
    step "Копирование конфигов в $DEST"
    [[ -d "$CONFIG_DIR" ]] || die "Не найдена папка config/ в репо: $CONFIG_DIR"

    local dirs=(btop cava fastfetch fish foot hypr micro noctalia spicetify wallust yazi)
    for d in "${dirs[@]}"; do
        if [[ -d "$CONFIG_DIR/$d" ]]; then
            mkdir -p "$DEST/$d"
            cp -r "$CONFIG_DIR/$d/." "$DEST/$d/"
            ok "→ $d"
        else
            warn "Пропуск: $CONFIG_DIR/$d не найден"
        fi
    done

    cp "$CONFIG_DIR/starship.toml" "$DEST/starship.toml"
    ok "→ starship.toml"
}

deploy_wallpapers() {
    step "Копирование обоев в $WALL_DIR"
    [[ -d "$REPO_DIR/wallpapers" ]] || { warn "Папка wallpapers не найдена в репо"; return 0; }
    mkdir -p "$WALL_DIR"
    cp -r "$REPO_DIR/wallpapers/." "$WALL_DIR/"
    ok "→ $WALL_DIR"

    if command -v wallust >/dev/null 2>&1 && [[ -f "$DEST/wallust/wallust.toml" ]]; then
        log "Генерация цветов wallust..."
        mkdir -p "$DEST/dunst" "$DEST/rofi" 2>/dev/null
        wallust run "$WALL_DIR"/* 2>/dev/null | head -1 || true
        ok "Wallust цвета сгенерированы"
    fi
}

post_install() {
    step "Post-install настройка"

    # GTK cursor
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true

    # GTK theme
    command -v nwg-look >/dev/null 2>&1 && nwg-look -a >/dev/null 2>&1 || true

    # Shell на fish
    if [[ "$SHELL" != *"fish"* ]]; then
        log "Текущий shell: $SHELL"
        if { prompt "Сменить shell на fish? [y/N]: "; read -r ans; [[ $ans =~ ^[Yy]$ ]]; }; then
            chsh -s "$(command -v fish)" && ok "Shell изменён на fish"
        fi
    fi

    ok "Post-install завершён"
}

health_check() {
    step "Health check"
    local issues=0

    for bin in hyprland foot fish starship fastfetch; do
        command -v "$bin" >/dev/null 2>&1 || { warn "Отсутствует бинарник: $bin"; ((issues++)); }
    done

    for f in hypr/hyprland.lua fish/config.fish fastfetch/config.jsonc starship.toml; do
        [[ -f "$DEST/$f" ]] || { warn "Нет конфига: $f"; ((issues++)); }
    done

    [[ -d "$WALL_DIR" ]] || { warn "Обои не скопированы"; ((issues++)); }

    if ((issues == 0)); then
        ok "Health check: всё ок"
    else
        warn "Найдено проблем: $issues (см. лог: $LOG_FILE)"
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
    echo -e "${BOLD}Установка полного профиля (Noctalia покрывает бар, лаунчер, обои, локскрин)${NC}"
    echo -e "Пакетов: ${#FULL_PKGS[@]} — ставим только недостающие\n"
    prompt "Нажми Enter для продолжения или Ctrl+C для отмены..."
    read -r

    check_root
    check_distro
    check_sudo

    ensure_aur_helper
    install_packages
    setup_fish
    backup_configs
    deploy_configs
    deploy_wallpapers
    post_install
    health_check

    echo -e "\n${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║                    УСТАНОВКА ЗАВЕРШЕНА                    ║${NC}"
    echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "  Конфиги:  ${CYAN}$DEST${NC}"
    echo -e "  Обои:     ${CYAN}$WALL_DIR${NC}"
    echo -e "  Бэкап:    ${CYAN}$BACKUP_DIR${NC}"
    echo -e "  Лог:      ${CYAN}$LOG_FILE${NC}"
    echo -e "  Ошибки:   ${CYAN}$ERROR_LOG${NC}"
    echo
    echo -e "  ${YELLOW}Следующие шаги:${NC}"
    echo -e "  1. ${CYAN}_exit${NC} в Hyprland (или перезайди в сессию)"
    echo -e "  2. ${CYAN}Super+A${NC} — терминал, ${CYAN}Super+R${NC} — лаунчер, ${CYAN}Super+/${NC} — cheatsheet"
    echo -e "  3. ${CYAN}Super+T${NC} — обои, ${CYAN}Super+V${NC} — буфер обмена"
    echo -e "  4. ${CYAN}Super+Shift+R${NC} — рестарт Noctalia"
    echo -e "  5. ${CYAN}Super+Space${NC} — float окно, ${CYAN}Super+mouse↑/↓${NC} — workspace"
    echo
    echo -e "  ${BLUE}Если что-то сломалось:${NC}"
    echo -e "  • Логи: ${CYAN}$LOG_FILE${NC} и ${CYAN}$ERROR_LOG${NC}"
    echo -e "  • Бэкап: ${CYAN}$BACKUP_DIR${NC} — можно вернуть: cp -r $BACKUP_DIR/* ~/.config/"
    echo -e "  • Issues: https://github.com/Minish777/hyprland-idk/issues"
    echo
}

main "$@"
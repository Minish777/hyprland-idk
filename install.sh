#!/usr/bin/env bash
# hyprland-idk installer — Arch/Arch-based
# Автоматизированная установка с профилями, бэкапами, сухой прогонкой и проверками

set -euo pipefail

# ===== КОНФИГУРАЦИЯ =====
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/config"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}"
WALL_DIR="$HOME/wallpapers"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/hyprland-idk-install-$(date +%Y%m%d-%H%M%S).log"

# Цвета
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; NC='\033[0m'

# ===== УТИЛИТЫ =====
log()   { echo -e "${CYAN}[*]${NC} $1" | tee -a "$LOG_FILE"; }
ok()    { echo -e "${GREEN}[+]${NC} $1" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
err()   { echo -e "${RED}[X]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
info()  { echo -e "${BLUE}[i]${NC} $1" | tee -a "$LOG_FILE"; }
step()  { echo -e "\n${CYAN}▶${NC} $1" | tee -a "$LOG_FILE"; }

# Глобальные флаги
DRY_RUN=false
FORCE=false
PROFILE="full"
SKIP_DEPS=false
SKIP_CONFIGS=false
SKIP_WALLPAPERS=false
BACKUP=true

# ===== ПРОФИЛИ ЗАВИСИМОСТЕЙ =====
declare -A PROFILE_PKGS=(
    [minimal]="hyprland foot fish starship fastfetch"
    [standard]="hyprland hyprpicker noctalia-git foot fish starship fastfetch eza zoxide micro yazi bat btop cava lazygit wl-clipboard cliphist gnome-keyring gammastep geoclue mpris-proxy hyprpicker zen-browser nautilus gnome-text-editor pwvucontrol ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme papirus-icon-theme spicetify-cli"
    [full]="hyprland hyprpicker noctalia-git foot fish starship fastfetch eza zoxide micro yazi bat broot btop cava lazygit wl-clipboard cliphist gnome-keyring gammastep geoclue mpris-proxy hyprpicker zen-browser nautilus gnome-text-editor pwvucontrol ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme papirus-icon-theme spicetify-cli wallust direnv zoxide waybar rofi-wayland dunst mako hypridle hyprlock grim slurp swappy cliphist"
)

# ===== ПОМОЩНИКИ =====
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Автоматизированная установка hyprland-idk rice (Arch/Arch-based)

ОПЦИИ:
    -p, --profile <name>    Профиль: minimal | standard | full (default: full)
    -n, --dry-run           Сухой прогон — ничего не меняет, только показывает что будет
    -f, --force             Перезаписать без подтверждений
    --skip-deps             Пропустить установку пакетов
    --skip-configs          Пропустить копирование конфигов
    --skip-wallpapers       Пропустить копирование обоев
    --no-backup             Не делать бэкап старых конфигов
    -h, --help              Показать эту справку

ПРИМЕРЫ:
    $0                      # Полная установка с подтверждениями
    $0 -p standard -f       # Стандартный профиль, без вопросов
    $0 -n                   # Показать что будет сделано
    $0 --skip-deps          # Только конфиги (пакеты уже стоят)

ПРОФИЛИ:
    minimal   — только Hyprland + bare minimum
    standard  — рабочий стол "из коробки"
    full      — всё + wallust, waybar, rofi, hyprlock, grim/slurp/swappy
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--profile) PROFILE="$2"; shift 2 ;;
            -n|--dry-run) DRY_RUN=true; shift ;;
            -f|--force) FORCE=true; shift ;;
            --skip-deps) SKIP_DEPS=true; shift ;;
            --skip-configs) SKIP_CONFIGS=true; shift ;;
            --skip-wallpapers) SKIP_WALLPAPERS=true; shift ;;
            --no-backup) BACKUP=false; shift ;;
            -h|--help) usage; exit 0 ;;
            *) err "Неизвестная опция: $1" ;;
        esac
    done

    [[ "${PROFILE_PKGS[$PROFILE]+_}" ]] || err "Неизвестный профиль: $PROFILE (minimal|standard|full)"
}

# Проверка окружения
check_env() {
    step "Проверка окружения"

    [[ $EUID -eq 0 ]] && err "Не запускай от root — скрипту нужен обычный пользователь с sudo."

    if ! grep -qi "arch\|manjaro\|endeavour\|garuda\|cachyos" /etc/os-release 2>/dev/null; then
        warn "Не Arch-based дистрибутив. Продолжить? (y/N)"
        $FORCE || read -r ans && [[ $ans =~ ^[Yy]$ ]] || exit 0
    fi

    if ! command -v pacman >/dev/null 2>&1; then
        err "pacman не найден"
    fi

    log "Профиль: $PROFILE"
    log "Dry-run: $DRY_RUN"
    log "Force: $FORCE"
    log "Backup: $BACKUP"
}

# AUR helper
ensure_aur_helper() {
    if command -v paru >/dev/null 2>&1 || command -v yay >/dev/null 2>&1; then
        return 0
    fi

    step "AUR helper не найден — ставим paru"
    $DRY_RUN && { info "DRY: pacman -S base-devel git && makepkg -si paru"; return 0; }

    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru-install
    (cd /tmp/paru-install && makepkg -si --noconfirm)
    rm -rf /tmp/paru-install
}

# Установка пакетов
install_packages() {
    $SKIP_DEPS && { info "Пропуск пакетов (--skip-deps)"; return 0; }

    step "Установка пакетов профиля '$PROFILE'"
    local pkgs="${PROFILE_PKGS[$PROFILE]}"
    local missing=()

    for pkg in $pkgs; do
        pacman -Q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done

    ((${#missing[@]} == 0)) && { ok "Все пакеты уже установлены"; return 0; }

    log "К установке: ${missing[*]}"
    $DRY_RUN && { info "DRY: paru -S --needed --noconfirm ${missing[*]}"; return 0; }

    if command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm "${missing[@]}"
    elif command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm "${missing[@]}"
    else
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi

    ok "Пакеты установлены"
}

# Fish plugins
setup_fish() {
    step "Настройка Fish (fisher + tide)"
    $DRY_RUN && { info "DRY: fisher install jorgebucaran/fisher && fisher install ilancosman/tide@v6"; return 0; }

    if ! command -v fish >/dev/null 2>&1; then
        warn "fish не установлен, пропуск"
        return 0
    fi

    fish -c 'fisher install jorgebucaran/fisher' >/dev/null 2>&1 || true
    fish -c 'fisher install ilancosman/tide@v6' >/dev/null 2>&1 || true
    ok "Fish plugins установлены"
}

# Бэкап старых конфигов
backup_configs() {
    $BACKUP || return 0

    step "Бэкап старых конфигов → $BACKUP_DIR"
    $DRY_RUN && { info "DRY: mkdir -p $BACKUP_DIR && cp -r ~/.config/* $BACKUP_DIR/ 2>/dev/null"; return 0; }

    mkdir -p "$BACKUP_DIR"
    local backed_up=0
    for d in btop cava fastfetch fish foot hypr micro noctalia spicetify wallust yazi; do
        [[ -d "$DEST/$d" ]] && { cp -r "$DEST/$d" "$BACKUP_DIR/" 2>/dev/null; ((backed_up++)); }
    done
    [[ -f "$DEST/starship.toml" ]] && { cp "$DEST/starship.toml" "$BACKUP_DIR/"; ((backed_up++)); }
    ((backed_up > 0)) && ok "Забэкаплено: $BACKUP_DIR" || info "Нет конфигов для бэкапа"
}

# Развёртывание конфигов
deploy_configs() {
    $SKIP_CONFIGS && { info "Пропуск конфигов (--skip-configs)"; return 0; }

    step "Копирование конфигов в $DEST"
    $DRY_RUN && { info "DRY: cp -r $CONFIG_DIR/* $DEST/"; return 0; }

    [[ -d "$CONFIG_DIR" ]] || err "Не найдена папка config/ в репо: $CONFIG_DIR"

    local dirs=(btop cava fastfetch fish foot hypr micro noctalia spicetify wallust yazi)
    for d in "${dirs[@]}"; do
        if [[ -d "$CONFIG_DIR/$d" ]]; then
            mkdir -p "$DEST/$d"
            cp -r "$CONFIG_DIR/$d/." "$DEST/$d/"
            ok "→ $d"
        fi
    done

    cp "$CONFIG_DIR/starship.toml" "$DEST/starship.toml"
    ok "→ starship.toml"
}

# Обои + wallust генерация
deploy_wallpapers() {
    $SKIP_WALLPAPERS && { info "Пропуск обоев (--skip-wallpapers)"; return 0; }

    step "Копирование обоев в $WALL_DIR"
    $DRY_RUN && { info "DRY: cp -r $REPO_DIR/wallpapers/* $WALL_DIR/"; return 0; }

    [[ -d "$REPO_DIR/wallpapers" ]] || { warn "Папка wallpapers не найдена в репо"; return 0; }

    mkdir -p "$WALL_DIR"
    cp -r "$REPO_DIR/wallpapers/." "$WALL_DIR/"
    ok "→ $WALL_DIR"

    # Wallust генерация цветов из обоев
    if command -v wallust >/dev/null 2>&1 && [[ -f "$DEST/wallust/wallust.toml" ]]; then
        log "Генерация цветов wallust..."
        mkdir -p "$DEST/dunst" "$DEST/rofi" 2>/dev/null
        $DRY_RUN || wallust run "$WALL_DIR"/* 2>/dev/null | head -1 || true
        ok "Wallust цвета сгенерированы"
    fi
}

# Post-install: разрешения, сервисы
post_install() {
    step "Post-install настройка"

    # GTK theme через nwg-look если есть
    if command -v nwg-look >/dev/null 2>&1; then
        $DRY_RUN || nwg-look -a >/dev/null 2>&1 || true
    fi

    # Обновление bashrc для fish как дефолтного shell
    if [[ "$SHELL" != *"fish"* ]]; then
        log "Текущий shell: $SHELL. Сменить на fish? (y/N)"
        $FORCE || read -r ans && [[ $ans =~ ^[Yy]$ ]] && chsh -s "$(command -v fish)"
    fi

    # GTK cursor fix
    $DRY_RUN || gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic" 2>/dev/null || true
    $DRY_RUN || gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true

    ok "Post-install завершён"
}

# Проверка здоровья
health_check() {
    step "Проверка установки (health check)"

    local issues=0

    # Проверка ключевых бинарников
    for bin in hyprland foot fish starship fastfetch; do
        command -v "$bin" >/dev/null 2>&1 || { warn "Отсутствует: $bin"; ((issues++)); }
    done

    # Проверка конфигов
    for f in hypr/hyprland.lua fish/config.fish fastfetch/config.jsonc starship.toml; do
        [[ -f "$DEST/$f" ]] || { warn "Нет конфига: $f"; ((issues++)); }
    done

    # Проверка обоев
    [[ -d "$WALL_DIR" ]] || { warn "Обои не скопированы"; ((issues++)); }

    if ((issues == 0)); then
        ok "Health check: всё ок"
    else
        warn "Найдено проблем: $issues"
    fi
}

# Саммари
summary() {
    echo -e "\n${GREEN}========================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${GREEN}  Установка завершена!${NC}" | tee -a "$LOG_FILE"
    echo -e "${GREEN}========================================${NC}" | tee -a "$LOG_FILE"
    echo
    echo -e "  Профиль:      ${CYAN}$PROFILE${NC}" | tee -a "$LOG_FILE"
    echo -e "  Конфиги:      ${CYAN}$DEST${NC}" | tee -a "$LOG_FILE"
    echo -e "  Обои:         ${CYAN}$WALL_DIR${NC}" | tee -a "$LOG_FILE"
    $BACKUP && echo -e "  Бэкап:        ${CYAN}$BACKUP_DIR${NC}" | tee -a "$LOG_FILE"
    echo -e "  Лог:          ${CYAN}$LOG_FILE${NC}" | tee -a "$LOG_FILE"
    echo
    echo -e "  ${YELLOW}Следующие шаги:${NC}" | tee -a "$LOG_FILE"
    echo -e "  1. ${CYAN}_exit${NC} в Hyprland (или перезайди в сессию)" | tee -a "$LOG_FILE"
    echo -e "  2. ${CYAN}Super+R${NC} — лаунчер, ${CYAN}Super+Space${NC} — терминал (foot)" | tee -a "$LOG_FILE"
    echo -e "  3. ${CYAN}Super+T${NC} — обои, ${CYAN}Super+V${NC} — буфер обмена" | tee -a "$LOG_FILE"
    echo -e "  4. ${CYAN}Super+Shift+R${NC} — рестарт Noctalia" | tee -a "$LOG_FILE"
    echo
    echo -e "  ${BLUE}Полезные команды:${NC}" | tee -a "$LOG_FILE"
    echo -e "  ${CYAN}hyprctl reload${NC} — перезагрузка Hyprland" | tee -a "$LOG_FILE"
    echo -e "  ${CYAN}noctalia msg settings-toggle${NC} — настройки" | tee -a "$LOG_FILE"
    echo -e "  ${CYAN}wallust run ~/wallpapers/your.jpg${NC} — сменить тему" | tee -a "$LOG_FILE"
    echo -e "${GREEN}========================================${NC}" | tee -a "$LOG_FILE"
}

# ===== MAIN =====
main() {
    parse_args "$@"
    check_env

    $DRY_RUN && warn "=== DRY RUN MODE — ничего не будет изменено ==="

    ensure_aur_helper
    install_packages
    setup_fish
    backup_configs
    deploy_configs
    deploy_wallpapers
    post_install
    health_check
    summary
}

main "$@"
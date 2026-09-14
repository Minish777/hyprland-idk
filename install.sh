#!/usr/bin/env bash
# hyprland-idk installer — Arch/Arch-based
# Интерактивная установка с меню, профилями, бэкапами, health check

set -euo pipefail

# ===== КОНФИГУРАЦИЯ =====
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/config"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}"
WALL_DIR="$HOME/wallpapers"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/hyprland-idk-install-$(date +%Y%m%d-%H%M%S).log"

# Цвета
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

# ===== УТИЛИТЫ =====
log()   { echo -e "${CYAN}[*]${NC} $1" | tee -a "$LOG_FILE"; }
ok()    { echo -e "${GREEN}[+]${NC} $1" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
err()   { echo -e "${RED}[X]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
info()  { echo -e "${BLUE}[i]${NC} $1" | tee -a "$LOG_FILE"; }
step()  { echo -e "\n${CYAN}▶${NC} ${BOLD}$1${NC}" | tee -a "$LOG_FILE"; }
prompt() { echo -ne "${YELLOW}[?]${NC} $1 " | tee -a "$LOG_FILE"; }

# Глобальные переменные выбора
PROFILE="full"
DO_DEPS=true
DO_CONFIGS=true
DO_WALLPAPERS=true
DO_BACKUP=true
FORCE=false
DRY_RUN=false

# ===== ПРОФИЛИ =====
declare -A PROFILE_PKGS=(
    [minimal]="hyprland foot fish starship fastfetch"
    [standard]="hyprland hyprpicker noctalia-git foot fish starship fastfetch eza zoxide micro yazi bat btop cava lazygit wl-clipboard cliphist gnome-keyring gammastep geoclue mpris-proxy hyprpicker zen-browser nautilus gnome-text-editor pwvucontrol ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme papirus-icon-theme spicetify-cli"
    [full]="hyprland hyprpicker noctalia-git foot fish starship fastfetch eza zoxide micro yazi bat broot btop cava lazygit wl-clipboard cliphist gnome-keyring gammastep geoclue mpris-proxy hyprpicker zen-browser nautilus gnome-text-editor pwvucontrol ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme papirus-icon-theme spicetify-cli wallust direnv zoxide waybar rofi-wayland dunst mako hypridle hyprlock grim slurp swappy cliphist"
)

declare -A PROFILE_DESC=(
    [minimal]="Минимальный: только Hyprland + bare minimum (foot, fish, starship, fastfetch)"
    [standard]="Стандартный: рабочий стол \"из коробки\" — все основные утилиты"
    [full]="Полный: всё + wallust, waybar, rofi, hyprlock, grim/slurp/swappy, direnv"
)

# ===== МЕНЮ =====
header() {
    clear
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║       hyprland-idk installer — Arch/Arch-based           ║${NC}"
    echo -e "${BOLD}${CYAN}║           Hyprland + Noctalia V5 rice                    ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
}

choose_profile() {
    header
    echo -e "${BOLD}Выберите профиль установки:${NC}"
    echo
    local options=("minimal" "standard" "full")
    local i=1
    for opt in "${options[@]}"; do
        echo -e "  ${CYAN}$i)${NC} ${BOLD}$opt${NC} — ${PROFILE_DESC[$opt]}"
        ((i++))
    done
    echo
    prompt "Ваш выбор [1-3] (Enter = full): "
    read -r choice
    case ${choice:-3} in
        1) PROFILE="minimal" ;;
        2) PROFILE="standard" ;;
        3) PROFILE="full" ;;
        *) PROFILE="full" ;;
    esac
    ok "Профиль: $PROFILE"
    sleep 0.3
}

choose_components() {
    header
    echo -e "${BOLD}Что устанавливать?${NC}"
    echo

    # Пакеты
    prompt "Установить пакеты? [Y/n]: "
    read -r ans
    [[ $ans =~ ^[Nn]$ ]] && DO_DEPS=false

    # Конфиги
    prompt "Копировать конфиги в ~/.config? [Y/n]: "
    read -r ans
    [[ $ans =~ ^[Nn]$ ]] && DO_CONFIGS=false

    # Обои
    prompt "Копировать обои в ~/wallpapers? [Y/n]: "
    read -r ans
    [[ $ans =~ ^[Nn]$ ]] && DO_WALLPAPERS=false

    # Бэкап
    prompt "Сделать бэкап старых конфигов? [Y/n]: "
    read -r ans
    [[ $ans =~ ^[Nn]$ ]] && DO_BACKUP=false

    # Force
    prompt "Пропускать подтверждения (force mode)? [y/N]: "
    read -r ans
    [[ $ans =~ ^[Yy]$ ]] && FORCE=true

    echo
}

confirm_start() {
    header
    echo -e "${BOLD}Итог:${NC}"
    echo -e "  Профиль:       ${CYAN}$PROFILE${NC}"
    echo -e "  Пакеты:        $($DO_DEPS && echo -e "${GREEN}да${NC}" || echo -e "${RED}нет${NC}")"
    echo -e "  Конфиги:       $($DO_CONFIGS && echo -e "${GREEN}да${NC}" || echo -e "${RED}нет${NC}")"
    echo -e "  Обои:          $($DO_WALLPAPERS && echo -e "${GREEN}да${NC}" || echo -e "${RED}нет${NC}")"
    echo -e "  Бэкап:         $($DO_BACKUP && echo -e "${GREEN}да${NC}" || echo -e "${RED}нет${NC}")"
    echo -e "  Force:         $($FORCE && echo -e "${GREEN}да${NC}" || echo -e "${RED}нет${NC}")"
    echo
    prompt "Начать установку? [Y/n]: "
    read -r ans
    [[ $ans =~ ^[Nn]$ ]] && { info "Отменено пользователем"; exit 0; }
    echo
}

# ===== ПРОВЕРКИ =====
check_distro() {
    step "Проверка дистрибутива"

    if [[ ! -f /etc/os-release ]]; then
        err "Не удалось определить дистрибутив (/etc/os-release отсутствует)"
    fi

    . /etc/os-release
    local id="${ID:-}" id_like="${ID_LIKE:-}"

    # Прямое совпадение
    case "$id" in
        arch|manjaro|endeavouros|garuda|cachyos|archarm|artix)
            ok "Обнаружен: $PRETTY_NAME"
            return 0
            ;;
    esac

    # Через ID_LIKE
    case " $id_like " in
        *" arch "*|*" manjaro "*|*" endeavouros "*|*" garuda "*|*" cachyos "*|*" artix "*|*" archarm "*)
            ok "Обнаружен Arch-based: $PRETTY_NAME"
            return 0
            ;;
    esac

    # Фоллбек: проверка pacman
    if command -v pacman >/dev/null 2>&1; then
        warn "Дистрибутив не в списке, но pacman найден: $PRETTY_NAME"
        if $FORCE; then
            ok "Force mode — продолжаем"
            return 0
        fi
        prompt "Продолжить на свой страх и риск? [y/N]: "
        read -r ans
        [[ $ans =~ ^[Yy]$ ]] || err "Отменено: не Arch-based дистрибутив"
        return 0
    fi

    err "Не Arch-based дистрибутив: $PRETTY_NAME (pacman не найден)"
}

check_root() {
    [[ $EUID -eq 0 ]] && err "Не запускай от root — скрипту нужен обычный пользователь с sudo."
}

check_sudo() {
    step "Проверка sudo"
    if ! sudo -n true 2>/dev/null; then
        log "Требуются права sudo..."
        sudo -v || err "Sudo не настроен или пароль неверен"
    fi
    ok "Sudo OK"
}

# ===== УСТАНОВКА =====
ensure_aur_helper() {
    if command -v paru >/dev/null 2>&1 || command -v yay >/dev/null 2>&1; then
        return 0
    fi

    step "AUR helper не найден — установка paru"
    $DRY_RUN && { info "DRY: pacman -S base-devel git && makepkg -si paru"; return 0; }

    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru-install
    (cd /tmp/paru-install && makepkg -si --noconfirm)
    rm -rf /tmp/paru-install
    ok "paru установлен"
}

install_packages() {
    $DO_DEPS || { info "Пропуск пакетов"; return 0; }

    step "Установка пакетов профиля '$PROFILE'"
    local pkgs="${PROFILE_PKGS[$PROFILE]}"
    local missing=()

    for pkg in $pkgs; do
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
    step "Настройка Fish (fisher + tide)"
    $DRY_RUN && { info "DRY: fisher install..."; return 0; }

    command -v fish >/dev/null 2>&1 || { warn "fish не установлен"; return 0; }

    fish -c 'fisher install jorgebucaran/fisher' >/dev/null 2>&1 || true
    fish -c 'fisher install ilancosman/tide@v6' >/dev/null 2>&1 || true
    ok "Fish plugins установлены"
}

backup_configs() {
    $DO_BACKUP || return 0

    step "Бэкап старых конфигов → $BACKUP_DIR"
    $DRY_RUN && { info "DRY: mkdir -p $BACKUP_DIR && cp -r ~/.config/* $BACKUP_DIR/"; return 0; }

    mkdir -p "$BACKUP_DIR"
    local count=0
    for d in btop cava fastfetch fish foot hypr micro noctalia spicetify wallust yazi; do
        [[ -d "$DEST/$d" ]] && { cp -r "$DEST/$d" "$BACKUP_DIR/" 2>/dev/null; ((count++)); }
    done
    [[ -f "$DEST/starship.toml" ]] && { cp "$DEST/starship.toml" "$BACKUP_DIR/"; ((count++)); }
    ((count > 0)) && ok "Забэкаплено $count папок: $BACKUP_DIR" || info "Нет конфигов для бэкапа"
}

deploy_configs() {
    $DO_CONFIGS || { info "Пропуск конфигов"; return 0; }

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

deploy_wallpapers() {
    $DO_WALLPAPERS || { info "Пропуск обоев"; return 0; }

    step "Копирование обоев в $WALL_DIR"
    $DRY_RUN && { info "DRY: cp -r $REPO_DIR/wallpapers/* $WALL_DIR/"; return 0; }

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

    # GTK theme via nwg-look
    command -v nwg-look >/dev/null 2>&1 && nwg-look -a >/dev/null 2>&1 || true

    # Смена shell на fish
    if [[ "$SHELL" != *"fish"* ]]; then
        log "Текущий shell: $SHELL"
        if $FORCE || { prompt "Сменить shell на fish? [y/N]: "; read -r ans; [[ $ans =~ ^[Yy]$ ]]; }; then
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
        warn "Найдено проблем: $issues"
    fi
}

# ===== САММАРИ =====
summary() {
    echo -e "\n${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║                    УСТАНОВКА ЗАВЕРШЕНА                    ║${NC}"
    echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "  ${BOLD}Профиль:${NC}      ${CYAN}$PROFILE${NC}"
    echo -e "  ${BOLD}Конфиги:${NC}      ${CYAN}$DEST${NC}"
    echo -e "  ${BOLD}Обои:${NC}         ${CYAN}$WALL_DIR${NC}"
    $DO_BACKUP && echo -e "  ${BOLD}Бэкап:${NC}        ${CYAN}$BACKUP_DIR${NC}"
    echo -e "  ${BOLD}Лог:${NC}          ${CYAN}$LOG_FILE${NC}"
    echo
    echo -e "  ${YELLOW}Следующие шаги:${NC}"
    echo -e "  1. ${CYAN}_exit${NC} в Hyprland (или перезайди в сессию)"
    echo -e "  2. ${CYAN}Super+A${NC} — терминал (foot), ${CYAN}Super+R${NC} — лаунчер"
    echo -e "  3. ${CYAN}Super+T${NC} — обои, ${CYAN}Super+V${NC} — буфер обмена"
    echo -e "  4. ${CYAN}Super+Shift+R${NC} — рестарт Noctalia"
    echo -e "  5. ${CYAN}Super+Space${NC} — float окно, ${CYAN}Super+mouse↑/↓${NC} — workspace"
    echo
    echo -e "  ${BLUE}Полезные команды:${NC}"
    echo -e "  ${CYAN}hyprctl reload${NC}           — перезагрузка Hyprland"
    echo -e "  ${CYAN}noctalia msg settings-toggle${NC} — настройки"
    echo -e "  ${CYAN}wallust run ~/wallpapers/xxx.jpg${NC} — сменить тему"
    echo
}

# ===== MAIN =====
main() {
    header
    echo -e "${BOLD}Добро пожаловать в установку hyprland-idk!${NC}"
    echo -e "Этот скрипт настроит Hyprland + Noctalia V5 rice.\n"
    prompt "Нажми Enter для продолжения..."
    read -r

    choose_profile
    choose_components
    confirm_start

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
    summary
}

main "$@"
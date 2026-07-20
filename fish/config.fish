# =============================================================================
# ПУТИ И ОКРУЖЕНИЕ (Выполняется всегда)
# =============================================================================

# Путь для Spicetify
fish_add_path /home/steelium/.spicetify

# Убираем стандартное приветствие fish при открытии
set -g fish_greeting ""

# =============================================================================
# ИНТЕРАКТИВНАЯ СЕССИЯ (Выполняется только в терминале)
# =============================================================================
if status is-interactive

    # Инициализация Starship промта
    starship init fish | source



    # -------------------------------------------------------------------------
    # Удобные алиасы (Сокращения команд)
    # -------------------------------------------------------------------------
    
    # Навигация и вывод списков (используем встроенный в Ultramarine инструмент eza с иконками)
    if type -q eza
        alias ls="eza --icons --group-directories-first"
        alias ll="eza -lh --icons --group-directories-first"
        alias la="eza -a --icons --group-directories-first"
        alias lla="eza -lah --icons --group-directories-first"
    else
        alias ls="ls --color=auto"
        alias ll="ls -lh"
        alias la="ls -a"
    end

    # Быстрый DNF5
    alias pinstall="sudo pacman -S"
    alias uninstall="sudo pacman -Rns"
    alias update="sudo pacman -Syu"

    # Системные утилиты
    alias grep="grep --color=auto"
    alias ..="cd .."
    alias ...="cd ../.."
    alias c="clear"

    # Быстрая перезагрузка конфигов "на лету"
    alias reload="source ~/.config/fish/config.fish"

end

# быстрые команды для управления zapret
alias zapret-config='$HOME/zapret-configs/install.sh'
alias zapret-utils='$HOME/zapret-configs/utils-zapret.sh'

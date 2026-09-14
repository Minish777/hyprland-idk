# hyprland-idk

My Linux rice — Hyprland + Noctalia V5 (Arch/Arch-based)

<img width="1920" height="1080" alt="изображение" src="https://github.com/user-attachments/assets/ef1c5cf6-e124-4012-b367-ed41ceec3b89" />

## Что внутри

| Что | Конфиг |
|---|---|
| Window Manager | Hyprland (Lua: `config/hypr/hyprland.lua`) |
| Shell/Док/Бар | Noctalia V5 (`config/noctalia/config.toml`) |
| Терминал | Foot |
| Shell | Fish + Starship + Tide |
| Лаунчер | Noctalia launcher (Super+R / Super+A) |
| Промпт | Starship (`config/starship.toml`) |
| Система-инфо | Fastfetch (`config/fastfetch`) |
| Файл-менеджер (TUI) | Yazi |
| Мониторинг | Btop, Cava |
| Редактор | Micro |
| Цвета от обоев | Wallust |
| Spotify | Spicetify (`config/spicetify`) |

Конфиги в `config/` зеркалируют `~/.config` — можно копировать вручную.

## Установка

> Требуется: Arch/Arch-based, пользователь с sudo, ~5G свободного места.

```bash
git clone https://github.com/Minish777/hyprland-idk
cd hyprland-idk
chmod +x install.sh
./install.sh           # полный профиль с вопросами
```

### Профили (`-p`)

| Профиль | Что включает |
|---|---|
| `minimal` | Только Hyprland + bare minimum (foot, fish, starship, fastfetch) |
| `standard` | Рабочий стол "из коробки" (все основные утилиты) |
| `full` | Всё + wallust, waybar, rofi, hyprlock, grim/slurp/swappy, direnv |

```bash
./install.sh -p standard      # стандартный
./install.sh -p minimal       # минимальный
./install.sh -p full -f       # полный без подтверждений
```

### Полезные флаги

```bash
./install.sh -n               # dry-run — покажет что будет, ничего не меняет
./install.sh --skip-deps      # только конфиги (пакеты уже стоят)
./install.sh --skip-configs   # только пакеты + обои
./install.sh --skip-wallpapers # без обоев
./install.sh --no-backup      # не бэкапить старые конфиги
```

### Что делает скрипт автоматически:

1. **AUR helper** — ставит `paru` (если нет `yay`/`paru`)
2. **Зависимости** — устанавливает только недостающие пакеты профиля
3. **Fish plugins** — `fisher` + `tide@v6`
4. **Бэкап** — старые конфиги в `~/.config-backup-YYYYMMDD-HHMMSS/`
5. **Деплой** — копирует `config/*` → `~/.config/`, `starship.toml`
6. **Обои** — `wallpapers/*` → `~/wallpapers/`
7. **Wallust** — генерирует цвета из обоев для dunst/rofi/gtk
8. **Post-install** — курсор Bibata, GTK theme, предложит сменить shell на fish
9. **Health check** — проверяет что всё на месте
10. **Саммари** — хоткеи, полезные команды, пути

После установки — выйти из сессии (`_exit` в Hyprland) и зайти заново.

## Горячие клавиши (после установки)

| Клавиша | Действие |
|---|---|
| `Super + A` / `Super + R` | Лаунчер / Noctalia лаунчер |
| `Super + Space` | Терминал (foot) |
| `Super + E` | Файловый менеджер (nautilus) |
| `Super + W` | Браузер (zen-browser) |
| `Super + T` | Селектор обоев |
| `Super + V` | Буфер обмена (cliphist) |
| `Super + S` | Центр управления |
| `Super + L` | Lock |
| `Super + Shift + R` | Рестарт Noctalia |
| `Super + Shift + S` | Скриншот области |
| `Print` | Скриншот экрана |
| `Super + C` | Редактор (gnome-text-editor) |
| `Alt + Tab` | Переключение окон |

## /home (отдельный раздел)

Тяжёлые данные живут на большом разделе `/home`, а не на корне:

- Кэш пакетов pacman → `/home/pacman-cache/` (`CacheDir` в `/etc/pacman.conf`)
- Flatpak → симлинк `/var/lib/flatpak` → `/home/$USER/.local/share/flatpak-system`
- Waydroid → симлинк `/var/lib/waydroid` → `/home/$USER/.local/share/waydroid-data`

Если у тебя маленький корневой раздел — сделай аналогично.

## Структура репо

```
hyprland-idk/
├── config/              # ~/.config mirror
│   ├── btop/
│   ├── cava/
│   ├── fastfetch/
│   ├── fish/
│   ├── foot/
│   ├── hypr/
│   ├── micro/
│   ├── noctalia/
│   ├── spicetify/
│   ├── wallust/
│   ├── yazi/
│   └── starship.toml
├── wallpapers/
├── install.sh           # автоматизированная установка
├── README.md
└── .gitignore
```

## Ручное копирование (без install.sh)

```bash
# Конфиги
cp -r config/* ~/.config/

# Starship
cp config/starship.toml ~/.config/

# Обои
cp -r wallpapers/* ~/wallpapers/

# Зависимости (Arch)
paru -S --needed --noconfirm hyprland foot fish starship fastfetch eza zoxide micro yazi bat btop cava lazygit wl-clipboard cliphist gnome-keyring gammastep geoclue mpris-proxy hyprpicker zen-browser nautilus gnome-text-editor pwvucontrol ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme papirus-icon-theme spicetify-cli wallust direnv

# Fish plugins
fish -c 'fisher install jorgebucaran/fisher && fisher install ilancosman/tide@v6'
```
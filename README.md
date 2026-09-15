# hyprland-idk

> **Hyprland + Noctalia V5 rice** for Arch/Arch-based distros

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/12730cf4-83c3-414f-a610-ce2ca561b62e" />


---

## Features

| Component | Config |
|-----------|--------|
| Window Manager | Hyprland (Lua: `config/hypr/hyprland.lua`) |
| Shell / Bar / Dock | Noctalia V5 (`config/noctalia/config.toml`) |
| Terminal | Foot (`Super + A`) |
| Shell | Fish + Starship + Tide |
| Launcher | Noctalia (`Super + R`) |
| Keybind Cheatsheet | Noctalia plugin — `Super + /` |
| Prompt | Starship (`config/starship.toml`) |
| System Info | Fastfetch (`config/fastfetch`) |
| File Manager (TUI) | Yazi |
| Monitoring | Btop, Cava |
| Editor | Micro |
| Wallpaper Colors | Wallust (optional, config included) |
| Spotify | Spicetify (`config/spicetify`) |

Configs in `config/` mirror `~/.config` — copy manually if needed.

---

## Quick Install

```bash
git clone https://github.com/Minish777/hyprland-idk
cd hyprland-idk
chmod +x install.sh
./install.sh
```

The script is **interactive**: it asks only for the optional steps (install `asar`?, switch shell to fish?), backs up existing configs and logs everything to `/tmp/`.

---

## What the Installer Does

1. **Detects distro** — verifies Arch/Arch-based (Manjaro, EndeavourOS, Garuda, CachyOS, Artix...)
2. **Installs AUR helper** — `paru` (if `yay`/`paru` missing)
3. **Installs packages** — only missing ones (single full profile, no menus)
4. **Optionally installs `asar`** — asked with `[y/N]` (needed for Electron apps / Discord forks; Arch repo, then AUR, then npm fallbacks)
5. **Sets up Fish** — `fisher` + `tide@v6`
6. **Backs up** — existing configs to `~/.config-backup-YYYYMMDD-HHMMSS/`
7. **Deploys configs** — `config/*` → `~/.config/`, `starship.toml`
8. **Copies wallpapers** — `wallpapers/*` → `~/wallpapers/`
9. **Generates colors** — Wallust from wallpapers, if installed (dunst, rofi)
10. **Post-install** — Bibata cursor, GTK theme, offers to switch shell to fish (`[y/N]`)
11. **Health check** — verifies everything works
12. **Shows summary** — hotkeys, useful commands, paths

---

## What Gets Installed

Single **full** profile — everything you need, no menu required:

- **Core:** `hyprland`, `hyprpicker`, `noctalia-git`, `foot`, `fish`, `starship`, `fastfetch`
- **CLI tools:** `eza`, `zoxide`, `micro`, `yazi`, `bat`, `broot`, `btop`, `cava`, `lazygit`
- **Clipboard / keys:** `wl-clipboard`, `cliphist`, `gnome-keyring`
- **Night light:** `gammastep`, `geoclue`, `mpris-proxy`
- **Apps:** `zen-browser`, `nautilus`, `gnome-text-editor`, `pwvucontrol`
- **Look:** `ttf-jetbrains-mono-nerd`, `noto-fonts`, `bibata-cursor-theme`, `papirus-icon-theme`
- **Extras:** `spicetify-cli`, `direnv`

> Noctalia covers bar, launcher, notifications, wallpapers, lockscreen and control-center — so `wallust`, `waybar`, `rofi` are not required.

---

## Post-Install Hotkeys

*(matches `config/hypr/hyprland/keybinds.lua`; press `Super + /` to open the in-session cheatsheet)*

**Windows**

| Key | Action |
|-----|--------|
| `Super + Q` | Close window |
| `Super + Escape` | Kill window |
| `Super + F` | Toggle fullscreen |
| `Super + D` | Maximize window |
| `Super + Space` | Toggle floating (900×600, centered) |
| `Super + ←/→/↑/↓` | Focus window in that direction |
| `Super + Shift + ←/→/↑/↓` | Move window in that direction |
| `Super + drag` | Drag window |
| `Super + right-click-drag` | Resize window |

**Apps**

| Key | Action |
|-----|--------|
| `Super + A` | Terminal (foot) |
| `Super + E` | File manager (nautilus) |
| `Super + R` | Launcher (Noctalia) |
| `Super + W` | Browser (zen-browser) |
| `Super + C` | Editor (gnome-text-editor) |

**System**

| Key | Action |
|-----|--------|
| `Super + S` | Control center |
| `Super + ,` | System settings |
| `Super + Shift + S` | Screenshot region |
| `Print` | Full screenshot |
| `Super + Shift + Alt + S` | Screenshot region (alt) |
| `Super + V` | Clipboard history (cliphist) |
| `Super + Shift + Alt + V` | Clear clipboard |
| `Ctrl + Shift + Alt + V` | Paste latest clipboard entry |
| `Super + X` | Session menu |
| `Super + L` | Lock screen |
| `Super + Shift + R` | Restart Noctalia |
| `Super + T` | Wallpaper selector |
| `Alt + Tab` | Window switcher |
| `Super + /` | **Keybind cheatsheet** |
| `Super + Shift + C` | Color picker (hyprpicker) |

**Workspaces**

| Key | Action |
|-----|--------|
| `Super + 1..0` | Switch to workspace 1–10 |
| `Super + Shift + 1..0` | Move window to workspace 1–10 |
| `Super + mouse wheel` | Previous / next workspace |

**Media & Volume**

| Key | Action |
|-----|--------|
| `Ctrl + Super + Space` | Play / pause (also `XF86AudioPlay`) |
| `Ctrl + Super + =` | Next track (`XF86AudioNext`) |
| `Ctrl + Super + -` | Previous track (`XF86AudioPrev`) |
| `Ctrl + Super + Backspace` | Stop media |
| `Super + Shift + M` | Mute volume (also `XF86AudioMute`) |
| `XF86AudioMicMute` | Mute mic |
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `Ctrl + Alt + V` | Audio settings (pwvucontrol) |

**Brightness & Power**

| Key | Action |
|-----|--------|
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |
| `Super + Shift + L` | Sleep |

---

## Disk Layout Tip (Small Root Partition)

If your `/` is small (e.g. 32GB), move heavy data to `/home`:

```bash
# Pacman cache
sudo mkdir -p /home/pacman-cache
# Edit /etc/pacman.conf: CacheDir = /home/pacman-cache/

# Flatpak
sudo mv /var/lib/flatpak /home/$USER/.local/share/flatpak-system
sudo ln -s /home/$USER/.local/share/flatpak-system /var/lib/flatpak

# Waydroid
sudo mv /var/lib/waydroid /home/$USER/.local/share/waydroid-data
sudo ln -s /home/$USER/.local/share/waydroid-data /var/lib/waydroid
```

---

## Repo Structure

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
├── install.sh           # Interactive installer
├── README.md
└── .gitignore
```

---

## Manual Install (without install.sh)

```bash
# Configs
cp -r config/* ~/.config/
cp config/starship.toml ~/.config/
cp -r wallpapers/* ~/wallpapers/

# Dependencies (Arch)
paru -S --needed --noconfirm hyprland hyprpicker noctalia-git \
    foot fish starship fastfetch \
    eza zoxide micro yazi bat btop cava lazygit wl-clipboard cliphist \
    gnome-keyring gammastep geoclue mpris-proxy \
    zen-browser nautilus gnome-text-editor pwvucontrol \
    ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme \
    papirus-icon-theme spicetify-cli direnv
# optional: color generation from wallpapers
paru -S --needed --noconfirm wallust

# Fish plugins
fish -c 'fisher install jorgebucaran/fisher && fisher install ilancosman/tide@v6'
```

---

<details>
<summary><b>🇷🇺 Русская версия / Russian Version</b></summary>

## Возможности

| Компонент | Конфиг |
|-----------|--------|
| Window Manager | Hyprland (Lua: `config/hypr/hyprland.lua`) |
| Shell / Бар / Док | Noctalia V5 (`config/noctalia/config.toml`) |
| Терминал | Foot (`Super + A`) |
| Shell | Fish + Starship + Tide |
| Лаунчер | Noctalia (`Super + R`) |
| Чит-лист биндов | Плагин Noctalia — `Super + /` |
| Промпт | Starship (`config/starship.toml`) |
| Системная инфо | Fastfetch (`config/fastfetch`) |
| Файловый менеджер (TUI) | Yazi |
| Мониторинг | Btop, Cava |
| Редактор | Micro |
| Цвета от обоев | Wallust (опционально, конфиг в комплекте) |
| Spotify | Spicetify (`config/spicetify`) |

Конфиги в `config/` зеркалят `~/.config`.

## Быстрая установка

```bash
git clone https://github.com/Minish777/hyprland-idk
cd hyprland-idk
chmod +x install.sh
./install.sh
```

Скрипт **интерактивен**: спрашивает только про опциональные шаги (установить `asar`?, сменить shell на fish?), делает бэкап конфигов и пишет логи в `/tmp/`.

## Что делает установщик

1. **Определяет дистрибутив** — проверяет Arch/Arch-based (Manjaro, EndeavourOS, Garuda, CachyOS, Artix...)
2. **Ставит AUR helper** — `paru` (если нет `yay`/`paru`)
3. **Ставит пакеты** — только недостающие (единый full-профиль, без меню)
4. **Опционально ставит `asar`** — спросит `[y/N]` (нужен для Electron-приложений и Discord-форков; репозиторий Arch, потом AUR, потом npm-фолбэки)
5. **Настраивает Fish** — `fisher` + `tide@v6`
6. **Бэкапит** — старые конфиги в `~/.config-backup-YYYYMMDD-HHMMSS/`
7. **Разворачивает конфиги** — `config/*` → `~/.config/`, `starship.toml`
8. **Копирует обои** — `wallpapers/*` → `~/wallpapers/`
9. **Генерирует цвета** — Wallust из обоев, если установлен (dunst, rofi)
10. **Post-install** — курсор Bibata, GTK тема, предложит сменить shell на fish (`[y/N]`)
11. **Health check** — проверяет что всё работает
12. **Показывает саммари** — хоткеи, полезные команды, пути

## Что ставится

Единый **full**-профиль — всё нужное из коробки, без меню:

- **Ядро:** `hyprland`, `hyprpicker`, `noctalia-git`, `foot`, `fish`, `starship`, `fastfetch`
- **CLI-утилиты:** `eza`, `zoxide`, `micro`, `yazi`, `bat`, `broot`, `btop`, `cava`, `lazygit`
- **Буфер обмена / ключи:** `wl-clipboard`, `cliphist`, `gnome-keyring`
- **Ночной свет:** `gammastep`, `geoclue`, `mpris-proxy`
- **Приложения:** `zen-browser`, `nautilus`, `gnome-text-editor`, `pwvucontrol`
- **Оформление:** `ttf-jetbrains-mono-nerd`, `noto-fonts`, `bibata-cursor-theme`, `papirus-icon-theme`
- **Дополнительно:** `spicetify-cli`, `direnv`

> Noctalia покрывает бар, лаунчер, уведомления, обои, локскрин и центр управления — поэтому `wallust`, `waybar`, `rofi` не нужны.

## Горячие клавиши (после установки)

*(совпадают с `config/hypr/hyprland/keybinds.lua`; `Super + /` — чит-лист всех биндов прямо в сессии)*

**Окна**

| Клавиша | Действие |
|---------|----------|
| `Super + Q` | Закрыть окно |
| `Super + Escape` | Убить окно |
| `Super + F` | Полноэкранный режим |
| `Super + D` | Развернуть окно |
| `Super + Space` | Float-режим (900×600, по центру) |
| `Super + ←/→/↑/↓` | Фокус на окно в сторону |
| `Super + Shift + ←/→/↑/↓` | Переместить окно в сторону |
| `Super + перетаскивание` | Перетаскивание окна |
| `Super + ПКМ-перетаскивание` | Изменение размера окна |

**Приложения**

| Клавиша | Действие |
|---------|----------|
| `Super + A` | Терминал (foot) |
| `Super + E` | Файловый менеджер (nautilus) |
| `Super + R` | Лаунчер (Noctalia) |
| `Super + W` | Браузер (zen-browser) |
| `Super + C` | Редактор (gnome-text-editor) |

**Система**

| Клавиша | Действие |
|---------|----------|
| `Super + S` | Центр управления |
| `Super + ,` | Настройки системы |
| `Super + Shift + S` | Скриншот области |
| `Print` | Скриншот экрана |
| `Super + Shift + Alt + S` | Скриншот области (альтернатива) |
| `Super + V` | Буфер обмена (cliphist) |
| `Super + Shift + Alt + V` | Очистить буфер |
| `Ctrl + Shift + Alt + V` | Вставить последний элемент буфера |
| `Super + X` | Меню сессии |
| `Super + L` | Блокировка |
| `Super + Shift + R` | Рестарт Noctalia |
| `Super + T` | Селектор обоев |
| `Alt + Tab` | Переключение окон |
| `Super + /` | **Чит-лист клавиш** |
| `Super + Shift + C` | Пипетка цвета (hyprpicker) |

**Workspace**

| Клавиша | Действие |
|---------|----------|
| `Super + 1..0` | Перейти на workspace 1–10 |
| `Super + Shift + 1..0` | Переместить окно на workspace 1–10 |
| `Super + колесо мыши` | Предыдущий / следующий workspace |

**Медиа и громкость**

| Клавиша | Действие |
|---------|----------|
| `Ctrl + Super + Space` | Играть / пауза (также `XF86AudioPlay`) |
| `Ctrl + Super + =` | Следующий трек (`XF86AudioNext`) |
| `Ctrl + Super + -` | Предыдущий трек (`XF86AudioPrev`) |
| `Ctrl + Super + Backspace` | Стоп медиа |
| `Super + Shift + M` | Без звука (также `XF86AudioMute`) |
| `XF86AudioMicMute` | Выключить микрофон |
| `XF86AudioRaiseVolume` | Громче |
| `XF86AudioLowerVolume` | Тише |
| `Ctrl + Alt + V` | Настройки аудио (pwvucontrol) |

**Яркость и питание**

| Клавиша | Действие |
|---------|----------|
| `XF86MonBrightnessUp` | Яркость вверх |
| `XF86MonBrightnessDown` | Яркость вниз |
| `Super + Shift + L` | Сон |

## Совет: маленький корневой раздел

Если `/` мало (например 32ГБ), перенеси тяжёлые данные на `/home`:

```bash
# Кэш pacman
sudo mkdir -p /home/pacman-cache
# /etc/pacman.conf: CacheDir = /home/pacman-cache/

# Flatpak
sudo mv /var/lib/flatpak /home/$USER/.local/share/flatpak-system
sudo ln -s /home/$USER/.local/share/flatpak-system /var/lib/flatpak

# Waydroid
sudo mv /var/lib/waydroid /home/$USER/.local/share/waydroid-data
sudo ln -s /home/$USER/.local/share/waydroid-data /var/lib/waydroid
```

## Структура репо

```
hyprland-idk/
├── config/              # зеркало ~/.config
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
├── install.sh           # интерактивный установщик
├── README.md
└── .gitignore
```

## Ручная установка (без install.sh)

```bash
# Конфиги
cp -r config/* ~/.config/
cp config/starship.toml ~/.config/
cp -r wallpapers/* ~/wallpapers/

# Зависимости (Arch)
paru -S --needed --noconfirm hyprland hyprpicker noctalia-git \
    foot fish starship fastfetch \
    eza zoxide micro yazi bat btop cava lazygit wl-clipboard cliphist \
    gnome-keyring gammastep geoclue mpris-proxy \
    zen-browser nautilus gnome-text-editor pwvucontrol \
    ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme \
    papirus-icon-theme spicetify-cli direnv
# опционально: генерация цветов из обоев
paru -S --needed --noconfirm wallust

# Fish plugins
fish -c 'fisher install jorgebucaran/fisher && fisher install ilancosman/tide@v6'
```

</details>

---

## License

MIT — use freely.

---

**Made with ❤️ for Arch Linux**

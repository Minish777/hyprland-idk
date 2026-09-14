# hyprland-idk

> **Hyprland + Noctalia V5 rice** for Arch/Arch-based distros

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/12730cf4-83c3-414f-a610-ce2ca561b62e" />


---

## Features

| Component | Config |
|-----------|--------|
| Window Manager | Hyprland (Lua: `config/hypr/hyprland.lua`) |
| Shell / Bar / Dock | Noctalia V5 (`config/noctalia/config.toml`) |
| Terminal | Foot |
| Shell | Fish + Starship + Tide |
| Launcher | Noctalia (Super+R / Super+A) |
| Prompt | Starship (`config/starship.toml`) |
| System Info | Fastfetch (`config/fastfetch`) |
| File Manager (TUI) | Yazi |
| Monitoring | Btop, Cava |
| Editor | Micro |
| Wallpaper Colors | Wallust |
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

The script is **fully interactive** — just run it and follow the menus.

---

## What the Installer Does

1. **Detects distro** — verifies Arch/Arch-based (Manjaro, EndeavourOS, Garuda, CachyOS, Artix...)
2. **Installs AUR helper** — `paru` (if `yay`/`paru` missing)
3. **Installs packages** — only missing ones for your chosen profile
4. **Sets up Fish** — `fisher` + `tide@v6`
5. **Backs up** — existing configs to `~/.config-backup-YYYYMMDD-HHMMSS/`
6. **Deploys configs** — `config/*` → `~/.config/`, `starship.toml`
7. **Copies wallpapers** — `wallpapers/*` → `~/wallpapers/`
8. **Generates colors** — Wallust from wallpapers (dunst, rofi, GTK)
9. **Post-install** — Bibata cursor, GTK theme, offers to switch shell to fish
10. **Health check** — verifies everything works
11. **Shows summary** — hotkeys, useful commands, paths

---

## Installation Profiles

| Profile | Packages | Use Case |
|---------|----------|----------|
| **minimal** | `hyprland foot fish starship fastfetch` | Bare bones, you add the rest |
| **standard** | All core utils + `zen-browser nautilus gnome-text-editor` | Daily driver out of the box |
| **full** | Everything + `wallust waybar rofi hyprlock grim slurp swappy direnv` | Complete rice experience |

> **Default:** `full` — choose in the interactive menu.

---

## Post-Install Hotkeys

| Key | Action |
|-----|--------|
| `Super + A` | Terminal (foot) |
| `Super + E` | File manager (nautilus) |
| `Super + R` | Launcher (Noctalia) |
| `Super + W` | Browser (zen-browser) |
| `Super + T` | Wallpaper selector |
| `Super + Space` | Toggle float + resize (900×600) + center |
| `Super + S` | Control center |
| `Super + Shift + S` | Screenshot region |
| `Super + V` | Clipboard history (cliphist) |
| `Super + L` | Lock screen |
| `Super + Shift + R` | Restart Noctalia |
| `Print` | Full screenshot |
| `Super + C` | Editor (gnome-text-editor) |
| `Alt + Tab` | Window switcher |
| `Super + mouse ↑/↓` | Prev/Next workspace |
| `Super + PgUp/PgDn` | Prev/Next workspace |
| `Ctrl + Super + ←/→` | Prev/Next workspace |
| `Super + Alt + mouse ↑/↓` | Move window to prev/next workspace |
| `Ctrl + Super + Shift + ←/→` | Move window to prev/next workspace |
| `Super + Shift + ←/→/↑/↓` | Move window direction |

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
paru -S --needed --noconfirm hyprland foot fish starship fastfetch \
    eza zoxide micro yazi bat btop cava lazygit wl-clipboard cliphist \
    gnome-keyring gammastep geoclue mpris-proxy hyprpicker \
    zen-browser nautilus gnome-text-editor pwvucontrol \
    ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme \
    papirus-icon-theme spicetify-cli wallust direnv

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
| Терминал | Foot |
| Shell | Fish + Starship + Tide |
| Лаунчер | Noctalia (Super+R / Super+A) |
| Промпт | Starship (`config/starship.toml`) |
| Системная инфо | Fastfetch (`config/fastfetch`) |
| Файловый менеджер (TUI) | Yazi |
| Мониторинг | Btop, Cava |
| Редактор | Micro |
| Цвета от обоев | Wallust |
| Spotify | Spicetify (`config/spicetify`) |

Конфиги в `config/` зеркалят `~/.config`.

## Быстрая установка

```bash
git clone https://github.com/Minish777/hyprland-idk
cd hyprland-idk
chmod +x install.sh
./install.sh
```

Скрипт **полностью интерактивен** — просто запусти и следуй меню.

## Что делает установщик

1. **Определяет дистрибутив** — проверяет Arch/Arch-based (Manjaro, EndeavourOS, Garuda, CachyOS, Artix...)
2. **Ставит AUR helper** — `paru` (если нет `yay`/`paru`)
3. **Ставит пакеты** — только недостающие для выбранного профиля
4. **Настраивает Fish** — `fisher` + `tide@v6`
5. **Бэкапит** — старые конфиги в `~/.config-backup-YYYYMMDD-HHMMSS/`
6. **Разворачивает конфиги** — `config/*` → `~/.config/`, `starship.toml`
7. **Копирует обои** — `wallpapers/*` → `~/wallpapers/`
8. **Генерирует цвета** — Wallust из обоев (dunst, rofi, GTK)
9. **Post-install** — курсор Bibata, GTK тема, предложит сменить shell на fish
10. **Health check** — проверяет что всё работает
11. **Показывает саммари** — хоткеи, полезные команды, пути

## Профили установки

| Профиль | Пакеты | Назначение |
|---------|--------|------------|
| **minimal** | `hyprland foot fish starship fastfetch` | Минимум, остальное сам |
| **standard** | Все базовые утилиты + `zen-browser nautilus gnome-text-editor` | Рабочий стол из коробки |
| **full** | Всё + `wallust waybar rofi hyprlock grim slurp swappy direnv` | Полный райс |

> **По умолчанию:** `full` — выбирается в меню.

## Горячие клавиши (после установки)

| Клавиша | Действие |
|---------|----------|
| `Super + A` | Терминал (foot) |
| `Super + E` | Файловый менеджер (nautilus) |
| `Super + R` | Лаунчер (Noctalia) |
| `Super + W` | Браузер (zen-browser) |
| `Super + T` | Селектор обоев |
| `Super + Space` | Toggle float + resize (900×600) + center |
| `Super + S` | Центр управления |
| `Super + Shift + S` | Скриншот области |
| `Super + V` | Буфер обмена (cliphist) |
| `Super + L` | Блокировка |
| `Super + Shift + R` | Рестарт Noctalia |
| `Print` | Скриншот экрана |
| `Super + C` | Редактор (gnome-text-editor) |
| `Alt + Tab` | Переключение окон |
| `Super + mouse ↑/↓` | Предидущий/следующий workspace |
| `Super + PgUp/PgDn` | Предидущий/следующий workspace |
| `Ctrl + Super + ←/→` | Предидущий/следующий workspace |
| `Super + Alt + mouse ↑/↓` | Переместить окно на prev/next workspace |
| `Ctrl + Super + Shift + ←/→` | Переместить окно на prev/next workspace |
| `Super + Shift + ←/→/↑/↓` | Переместить окно по направлению |

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
paru -S --needed --noconfirm hyprland foot fish starship fastfetch \
    eza zoxide micro yazi bat btop cava lazygit wl-clipboard cliphist \
    gnome-keyring gammastep geoclue mpris-proxy hyprpicker \
    zen-browser nautilus gnome-text-editor pwvucontrol \
    ttf-jetbrains-mono-nerd noto-fonts bibata-cursor-theme \
    papirus-icon-theme spicetify-cli wallust direnv

# Fish plugins
fish -c 'fisher install jorgebucaran/fisher && fisher install ilancosman/tide@v6'
```

</details>

---

## License

MIT — use freely.

---

**Made with ❤️ for Arch Linux**

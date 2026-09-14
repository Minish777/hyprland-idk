# hyprland-idk

My Linux rice — Hyprland + Noctalia V5 (Arch/Arch-based)

<img width="1920" height="1080" alt="изображение" src="https://github.com/user-attachments/assets/ef1c5cf6-e124-4012-b367-ed41ceec3b89" />

## Что внутри

| Что | Конфиг |
|---|---|
| Window Manager | Hyprland (Lua: `config/hypr/hyprland.lua`) |
| Shell/Док/Бар | Noctalia V5 (`config/noctalia/config.toml`) |
| Терминал | Foot (+ Kitty template) |
| Shell | Fish + Starship + Tide |
| Лаунчер | Noctalia launcher (Super+A/R) |
| Промпт | Starship (`config/starship.toml`) |
| Система-инфо | Fastfetch (`config/fastfetch`) |
| Файл-менеджер (TUI) | Yazi |
| Мониторинг | Btop, Cava |
| Редактор | Micro |
| Цвета от обоев | Wallust |
| Spotify | Spicetify (`config/spicetify`) |

Также: `config/` зеркалирует `~/.config` — можно копировать вручную.

## Установка

> Требуется: Arch/Arch-based, пользователь с sudo, ~5G свободного места.

```bash
git clone https://github.com/Minish777/hyprland-idk
cd hyprland-idk
chmod +x install.sh
./install.sh
```

Скрипт сам:
1. Ставит **paru** (если нет yay/paru)
2. Устанавливает все зависимости из `config/` (Hyprland, Noctalia, Fish, Starship, Fastfetch, Foot, Yazi, Btop, Cava, Micro, Wallust, Spicetify, Eza, Zoxide...)
3. Копирует конфиги в `~/.config`
4. Ставит fisher + tide для fish
5. Копирует обои в `~/wallpapers`
6. Генерирует цвета wallust из обоев

После установки — выйти из сессии (`_exit`) и зайти заново.

## Вручную

```bash
paru -S --needed --noconfirm noctalia-git
sudo pacman -S --needed --noconfirm hyprland foot fish starship fastfetch hyprpicker git
```

## /home

Отдельная фишка риса: тяжёлые данные живут на большом разделе `/home`, а не на корне:

- Кэш пакетов pacman → `/home/pacman-cache/` (`CacheDir` в `/etc/pacman.conf`)
- Flatpak → симлинк `/var/lib/flatpak` → `/home/$USER/.local/share/flatpak-system`
- Waydroid → симлинк `/var/lib/waydroid` → `/home/$USER/.local/share/waydroid-data`

Если у тебя маленький корневой раздел — сделай аналогично.
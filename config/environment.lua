-- Environmental variables

-- ==========================================
-- НАСТРОЙКИ NVIDIA И КУРСОРОВ ДЛЯ HYPRLAND 0.55
-- ==========================================

-- Заставляем бэкенд EGL/GBM работать корректно на Nvidia
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Включаем аппаратное ускорение видео для Nvidia
hl.env("LIBVA_DRIVER_NAME", "nvidia")

-- Отключаем VRR/G-Sync по умолчанию во избежание проблем в играх (рекомендация вики)
hl.env("__GL_VRR_ALLOWED", "0")

-- Базовые переменные окружения сессии Wayland
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Заставляем тулкиты и игры понимать Wayland
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

hl.config({
    -- 1. Включаем master-лаяут
    general = {
        layout = "master", 
    },
    
    -- 2. Настройки лаяута строго по актуальной документации
    master = {
        new_status = "master",                 -- Новые окна автоматически становятся главными (как в dwm)
        new_on_top = true,                     -- Новые slave-окна падают наверх стека
        mfact = 0.55,                          -- Главное окно занимает 55% ширины экрана
        orientation = "left",                  -- Положение мастера: left, right, top, bottom, center
        smart_resizing = true,                 -- Умный ресайз границ
        drop_at_cursor = true,                 -- Drag-and-drop окон по курсору
    },

    -- 3. Системная база
    misc = {
        col = {
            splash = CACHYLGREEN,
        },
        middle_click_paste = false,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
        vrr = 1,                               -- Адаптивная синхронизация для игр
        disable_hyprland_logo = true,          -- Чистый запуск без логотипов
        disable_splash_rendering = true,
    },

    xwayland = {
        force_zero_scaling = true
    },

    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },

    cursor = {
    	no_hardware_cursors = true
    },
})

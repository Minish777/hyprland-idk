-- Look and feel configuration

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 8,
        border_size = 2,
        extend_border_grab_area = 10,
        resize_on_border = true,
        col = {
            active_border = { colors = { CACHYLGREEN, CACHYDGREEN }, angle = 45 },
            inactive_border = CACHYGRAY,
        },
    },
    group = {
        col = {
            border_active = CACHYLBLUE,
            border_inactive = CACHYGRAY,
            border_locked_active = CACHYDBLUE,
            border_locked_inactive = CACHYGRAY,
        },
        groupbar = {
            col = {
                active = CACHYLGREEN,
                inactive = CACHYGRAY,
                locked_active = CACHYDBLUE,
                locked_inactive = CACHYGRAY,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 12,
        -- Настройки v5 для корректной отрисовки шелла
        rounding_power = 2, 
        
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1,
        
        blur = {
            enabled = true, -- Глобально вкл., отключается точечно через no_blur в windowrules.lua
            size = 6,
            passes = 2,
            -- Отключены «новые оптимизации» для совместимости с NVIDIA/EGL
            new_optimizations = false,
            ignore_opacity = true,
            xray = false,
        },

        -- Добавлены настройки теней для Noctalia v5
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
    },
    render = {
        -- Фикс пропавшего блюра на NVIDIA/fp16: шейдерный блюр-блендинг
        use_shader_blur_blend = true,
        -- Полное отключение fp16 (главный подозреваемый в пропаже блюра)
        use_fp16 = 0,
        keep_unmodified_copy = 0,
        -- Отключение color management (конфликтует с blur на NVIDIA)
        cm_enabled = false,
    },
})

-- Look and feel configuration

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 8,
        border_size = 0, -- Убираем обводку (ставим 0)
        extend_border_grab_area = 10,
        resize_on_border = true,
        -- Так как border_size 0, блок col для границ можно оставить пустым или убрать
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
        rounding = 10,
        active_opacity = 1.0,  -- Ставим 1.0 (полная непрозрачность снижает нагрузку)
        inactive_opacity = 1.0, -- Ставим 1.0
        fullscreen_opacity = 1,
        blur = {
            enabled = true,
            size = 5,
            passes = 2,        -- Снижаем количество проходов с 4 до 2 для GTX 1050
            new_optimizations = true,
            xray = true,
        },
    },
})

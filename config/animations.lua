-- Кривые
hl.curve("fast", { type = "bezier", points = { {0.15, 0.85}, {0.3, 1} } })

-- Анимации
hl.animation({ leaf = "global",     enabled = true, speed = 6, bezier = "fast" })
hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "fast", style = "popin 80%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "fast", style = "fade" })

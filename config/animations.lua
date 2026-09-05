-- Плавная кривая: мягкий старт и плавное затухание в конце (cubic-bezier ease)
hl.curve("soft_ease", { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })
-- Мягкий overshoot для лёгкого отталкивания воркспейсов
hl.curve("overshoot_soft", { type = "bezier", points = { {0.34, 0.0}, {0.4, 1.1} } })

-- Анимации. speed = децисекунды (100ms каждая): 1 = 100ms, 2 = 200ms и т.д.
hl.animation({ leaf = "global",     enabled = true, speed = 2, bezier = "soft_ease" })
-- Окна: popin при открытии (лёгкий зум), slide при закрытии
hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "soft_ease", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "soft_ease", style = "slide" })
-- Воркспейсы: slidefade с перемещением 20% и мягким затуханием («отталкивание»)
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "overshoot_soft", style = "slidefade 20%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2, bezier = "soft_ease" })

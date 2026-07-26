-- Идеально сбалансированная кривая: мягкий старт и плавное закругление в конце
hl.curve("smooth_slide", { type = "bezier", points = { {0.1, 0.9}, {0.2, 1.0} } })

-- Анимации (везде чистый slide, но с крутой кривой)
hl.animation({ leaf = "global",     enabled = true, speed = 4, bezier = "smooth_slide" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "smooth_slide", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "smooth_slide", style = "slide" })

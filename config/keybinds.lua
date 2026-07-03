local mainMod = "SUPER"
local noctCall = "qs -c noctalia-shell ipc call "
local launchPrefix = "" -- Убрали UWSM

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Закрытие и управление
hl.bind(mainMod .. " + Q",            hl.dsp.window.close())
hl.bind(mainMod .. " + Escape",       hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + F",            hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + D",            hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + Space",        hl.dsp.window.float({ action = "toggle" }))

-- Фокус (стрелки)
hl.bind(mainMod .. " + Left",         hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right",        hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up",           hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",         hl.dsp.focus({ direction = "down" }))

-- Перемещение окон (Shift + стрелки)
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))

------------------
---- LAUNCHER ----
------------------

hl.bind(mainMod .. " + Return",       hl.dsp.exec_cmd(TERMINAL))
hl.bind(mainMod .. " + E",            hl.dsp.exec_cmd(FILE_MANAGER))
hl.bind(mainMod .. " + R",            hl.dsp.exec_cmd(noctCall .. "launcher toggle")) -- Win+R как в винде
hl.bind(mainMod .. " + W",            hl.dsp.exec_cmd(BROWSER))

-------------------
---- UTILITIES ----
-------------------

-- Скриншоты (Win+Shift+S)
hl.bind(mainMod .. " + SHIFT + S",    hl.dsp.exec_cmd(noctCall .. "plugin:screen-toolkit annotate"))

-- Clipboard
hl.bind(mainMod .. " + V",            hl.dsp.exec_cmd(noctCall .. "launcher clipboard"))

-- Управление сессией
hl.bind(mainMod .. " + L",            hl.dsp.exec_cmd(noctCall .. "lockScreen lock"))
hl.bind(mainMod .. " + X",            hl.dsp.exec_cmd(noctCall .. "sessionMenu toggle"))

--------------------
---- WORKSPACES ----
--------------------

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Скролл воркспейсов
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Перетаскивание окон (SUPER + Левая кнопка мыши)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Изменение размера окон (SUPER + Правая кнопка мыши)
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local mainMod = "SUPER"
-- IPC-префикс строго по новой документации Noctalia v5
local ipc = "noctalia msg "

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Закрытие и управление окнами
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
hl.bind(mainMod .. " + R",            hl.dsp.exec_cmd(ipc .. "panel-toggle launcher")) -- Win+R Лаунчер v5
hl.bind(mainMod .. " + W",            hl.dsp.exec_cmd(BROWSER))

-------------------
---- UTILITIES ----
-------------------

-- Вызов Контрольного Центра (Win+S)
hl.bind(mainMod .. " + S",            hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))

-- Вызов настроек Noctalia (Win + запятая)
hl.bind(mainMod .. " + comma",        hl.dsp.exec_cmd(ipc .. "settings-toggle"))

-- Скриншот выделенной области (Win+Shift+S)
hl.bind(mainMod .. " + SHIFT + S",    hl.dsp.exec_cmd(ipc .. "screenshot-region"))

-- Буфер обмена (Win+V)
hl.bind(mainMod .. " + V",            hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))

-- Меню выхода / сессии (Win + X)
hl.bind(mainMod .. " + X",            hl.dsp.exec_cmd(ipc .. "panel-toggle session"))

-- Экран блокировки (Win + L)
hl.bind(mainMod .. " + L",            hl.dsp.exec_cmd(ipc .. "session lock"))

-- Перезапуск Noctalia (Win+Shift+R)
hl.bind(mainMod .. " + SHIFT + R",    hl.dsp.exec_cmd("noctalia quit; sleep 0.3; noctalia"))

-- Рандомная смена обоев на (Win + T)
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("noctalia msg wallpaper-random"))

--------------------
---- MEDIA KEYS ----
--------------------

-- Управление звуком и яркостью (System Controls)
hl.bind("XF86AudioRaiseVolume",       hl.dsp.exec_cmd(ipc .. "volume-up"))
hl.bind("XF86AudioLowerVolume",       hl.dsp.exec_cmd(ipc .. "volume-down"))
hl.bind("XF86AudioMute",              hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86MonBrightnessUp",        hl.dsp.exec_cmd(ipc .. "brightness-up"))
hl.bind("XF86MonBrightnessDown",      hl.dsp.exec_cmd(ipc .. "brightness-down"))

-- Управление плеером (Media MPRIS)
hl.bind("XF86AudioPlay",              hl.dsp.exec_cmd(ipc .. "media toggle"))
hl.bind("XF86AudioNext",              hl.dsp.exec_cmd(ipc .. "media next"))
hl.bind("XF86AudioPrev",              hl.dsp.exec_cmd(ipc .. "media previous"))

--------------------
---- WORKSPACES ----
--------------------

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Скролл воркспейсов мышкой
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Перетаскивание и ресайз окон мышью (SUPER + ЛКМ / ПКМ)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local vars = require("variables")
local fn   = require("utils.functions")

-- Flags
local locked           = { locked = true }
local mouse            = { mouse = true }
local release          = { release = true }
local repeating        = { repeating = true }
local locked_repeating = { locked = true, repeating = true }

local function normalise_keybind(key)
    return key:gsub("%s+", ""):lower()
end

local function valid_keybind(key)
    return type(key) == "string" and key:match("%S") ~= nil
end

local function repeating_unless_mouse(key)
    return not normalise_keybind(key):find("mouse", 1, true) and repeating or nil
end

local function flatten_keybinds(keybinds, keys)
    keys = keys or {}

    if type(keybinds) == "table" then
        for _, keybind in pairs(keybinds) do
            flatten_keybinds(keybind, keys)
        end
    elseif valid_keybind(keybinds) then
        keys[#keys + 1] = keybinds
    end

    return keys
end

local function create_bind(keybinds, action, flags)
    local get_flags = type(flags) == "function" and flags or function()
        return flags
    end

    for _, key in ipairs(flatten_keybinds(keybinds)) do
        hl.bind(key, action, get_flags(key))
    end
end

local function extend_keybind(base, suffix)
    return valid_keybind(base) and base .. " + " .. suffix or nil
end

local ipc = "noctalia msg "

----------------------------
---- WINDOW MANAGEMENT -----
----------------------------

create_bind("SUPER + Q",        hl.dsp.window.close())
create_bind("SUPER + Escape",   hl.dsp.exec_cmd("hyprctl kill"))
create_bind("SUPER + F",        hl.dsp.window.fullscreen())
create_bind("SUPER + D",        hl.dsp.window.fullscreen({ mode = 1 }))
create_bind("SUPER + Space",    hl.dsp.window.float({ action = "toggle" }))

-- Focus (arrows)
create_bind("SUPER + Left",     hl.dsp.focus({ direction = "left" }))
create_bind("SUPER + Right",    hl.dsp.focus({ direction = "right" }))
create_bind("SUPER + Up",       hl.dsp.focus({ direction = "up" }))
create_bind("SUPER + Down",     hl.dsp.focus({ direction = "down" }))

-- Move windows (Shift + arrows)
create_bind("SUPER + SHIFT + Left",   hl.dsp.window.move({ direction = "l" }))
create_bind("SUPER + SHIFT + Right",  hl.dsp.window.move({ direction = "r" }))
create_bind("SUPER + SHIFT + Up",     hl.dsp.window.move({ direction = "u" }))
create_bind("SUPER + SHIFT + Down",   hl.dsp.window.move({ direction = "d" }))

---------------------------
---------- LAUNCHER -------
---------------------------

create_bind("SUPER + A",       hl.dsp.exec_cmd(vars.terminal))
create_bind("SUPER + E",       hl.dsp.exec_cmd(vars.fileExplorer))
create_bind("SUPER + R",       hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
create_bind("SUPER + W",       hl.dsp.exec_cmd(vars.browser))

---------------------------
---------- UTILITIES ------
---------------------------

-- Control center
create_bind("SUPER + S",       hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))

-- Settings
create_bind("SUPER + comma",   hl.dsp.exec_cmd(ipc .. "settings-toggle"))

-- Screenshot region
create_bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))

-- Clipboard
create_bind("SUPER + V",       hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))

-- Session menu
create_bind("SUPER + X",       hl.dsp.exec_cmd(ipc .. "panel-toggle session"))

-- Lock
create_bind("SUPER + L",       hl.dsp.exec_cmd(ipc .. "session lock"))

-- Restart shell
create_bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("pkill noctalia; sleep 0.3; nohup noctalia --daemon >/dev/null 2>&1 &"), release)

-- Random wallpaper
create_bind("SUPER + T",       hl.dsp.exec_cmd(ipc .. "wallpaper-random"))

-- Window switcher
create_bind("ALT + TAB",       hl.dsp.exec_cmd(ipc .. "window-switcher"))

---------------------------
--------- WORKSPACES ------
---------------------------

for i = 1, 10 do
    local key = i % 10
    create_bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }))
    create_bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Scroll workspaces with mouse
create_bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
create_bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Drag and resize with mouse
create_bind("SUPER + mouse:272", hl.dsp.window.drag(), mouse)
create_bind("SUPER + mouse:273", hl.dsp.window.resize(), mouse)

---------------------------
---------- APPS -----------
---------------------------

create_bind(vars.kbEditor,      hl.dsp.exec_cmd(vars.editor))
create_bind(vars.kbAudioSettings, hl.dsp.exec_cmd(vars.audioSettings))

---------------------------
-------- UTILITIES ---------
---------------------------

-- Screenshot fullscreen
create_bind(vars.kbScreenshot,        hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"), locked)
create_bind(vars.kbScreenshotRegion,  hl.dsp.exec_cmd(ipc .. "screenshot-region"))

-- Color picker
create_bind(vars.kbColorPicker,  hl.dsp.exec_cmd("hyprpicker -a"))

---------------------------
-------- BRIGHTNESS --------
---------------------------

create_bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd(ipc .. "brightness-up"), locked)
create_bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd(ipc .. "brightness-down"), locked)

---------------------------
---------- MEDIA -----------
---------------------------

create_bind({ vars.kbMediaToggle, "XF86AudioPlay", "XF86AudioPause" }, hl.dsp.exec_cmd(ipc .. "media toggle"), locked)
create_bind({ vars.kbMediaNext, "XF86AudioNext" },   hl.dsp.exec_cmd(ipc .. "media next"), locked)
create_bind({ vars.kbMediaPrev, "XF86AudioPrev" },   hl.dsp.exec_cmd(ipc .. "media previous"), locked)
create_bind({ vars.kbMediaStop, "XF86AudioStop" },   hl.dsp.exec_cmd(ipc .. "media stop"), locked)

---------------------------
---------- VOLUME ----------
---------------------------

create_bind({ vars.kbVolumeMute, "XF86AudioMute" }, hl.dsp.exec_cmd(ipc .. "volume-mute"), locked)
create_bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "mic-mute"), locked)
create_bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), locked_repeating)
create_bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), locked_repeating)

---------------------------
---------- SLEEP -----------
---------------------------

create_bind(vars.kbSleep, hl.dsp.exec_cmd(vars.sleepGestureCmd), locked)

---------------------------
---- CLIPBOARD ----
---------------------------

create_bind(vars.kbClipboardDel, hl.dsp.exec_cmd(ipc .. "clipboard-clear"))
create_bind(
    vars.kbClipboardPasteLatest,
    hl.dsp.exec_cmd('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'),
    locked
)
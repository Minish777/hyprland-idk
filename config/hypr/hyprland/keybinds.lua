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

-- 1. Window Management
create_bind("SUPER + Q",        hl.dsp.window.close(), { desc = "Close window" })
create_bind("SUPER + Escape",   hl.dsp.exec_cmd("hyprctl kill"), { desc = "Kill window" })
create_bind("SUPER + F",        hl.dsp.window.fullscreen(), { desc = "Toggle fullscreen" })
create_bind("SUPER + D",        hl.dsp.window.fullscreen({ mode = 1 }), { desc = "Maximize window" })
create_bind("SUPER + Space",    function() hl.dispatch(hl.dsp.window.float({ action = "toggle" })); hl.dispatch(hl.dsp.window.resize({ x = 900, y = 600 })); hl.dispatch(hl.dsp.window.center()) end, { desc = "Toggle floating" })
create_bind("SUPER + Left",     hl.dsp.focus({ direction = "left" }), { desc = "Focus left" })
create_bind("SUPER + Right",    hl.dsp.focus({ direction = "right" }), { desc = "Focus right" })
create_bind("SUPER + Up",       hl.dsp.focus({ direction = "up" }), { desc = "Focus up" })
create_bind("SUPER + Down",     hl.dsp.focus({ direction = "down" }), { desc = "Focus down" })
create_bind("SUPER + SHIFT + Left",   hl.dsp.window.move({ direction = "l" }), { desc = "Move window left" })
create_bind("SUPER + SHIFT + Right",  hl.dsp.window.move({ direction = "r" }), { desc = "Move window right" })
create_bind("SUPER + SHIFT + Up",     hl.dsp.window.move({ direction = "u" }), { desc = "Move window up" })
create_bind("SUPER + SHIFT + Down",   hl.dsp.window.move({ direction = "d" }), { desc = "Move window down" })
create_bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, desc = "Drag window" })
create_bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, desc = "Resize window" })

-- 2. Applications
create_bind("SUPER + A",       hl.dsp.exec_cmd(vars.terminal), { desc = "Open terminal" })
create_bind("SUPER + E",       hl.dsp.exec_cmd(vars.fileExplorer), { desc = "Open files" })
create_bind("SUPER + R",       hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"), { desc = "Open launcher" })
create_bind("SUPER + W",       hl.dsp.exec_cmd(vars.browser), { desc = "Open browser" })
create_bind(vars.kbEditor,     hl.dsp.exec_cmd(vars.editor), { desc = "Open editor" })

-- 3. System
create_bind("SUPER + S",       hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"), { desc = "Control center" })
create_bind("SUPER + comma",   hl.dsp.exec_cmd(ipc .. "settings-toggle"), { desc = "System settings" })
create_bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(ipc .. "screenshot-region"), { desc = "Screenshot region" })
create_bind(vars.kbScreenshot,        hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"), { locked = true, desc = "Screenshot fullscreen" })
create_bind(vars.kbScreenshotRegion,  hl.dsp.exec_cmd(ipc .. "screenshot-region"), { desc = "Screenshot region (alt)" })
create_bind("SUPER + V",       hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"), { desc = "Clipboard" })
create_bind("SUPER + X",       hl.dsp.exec_cmd(ipc .. "panel-toggle session"), { desc = "Session menu" })
create_bind("SUPER + L",       hl.dsp.exec_cmd(ipc .. "session lock"), { desc = "Lock screen" })
create_bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("pkill noctalia; sleep 0.5; nohup noctalia " .. "-" .. "-daemon >/dev/null 2>&1 &"), { desc = "Restart shell" })
create_bind("SUPER + T",       hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"), { desc = "Wallpaper selector" })
create_bind("ALT + TAB",       hl.dsp.exec_cmd(ipc .. "window-switcher"), { desc = "Window switcher" })
create_bind(vars.kbCheatsheet, hl.dsp.exec_cmd(ipc .. "panel-toggle kenn/keybind-cheatsheet:cheatsheet"), { desc = "Keybind cheatsheet" })
create_bind(vars.kbColorPicker,  hl.dsp.exec_cmd("hyprpicker -a"), { desc = "Color picker" })
create_bind(vars.kbClipboardDel, hl.dsp.exec_cmd(ipc .. "clipboard-clear"), { desc = "Clear clipboard" })
create_bind(
    vars.kbClipboardPasteLatest,
    hl.dsp.exec_cmd('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'),
    { locked = true, desc = "Paste latest clipboard" }
)

-- 4. Workspaces
for i = 1, 10 do
    local key = i % 10
    create_bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }), { desc = "Workspace " .. i })
    create_bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }), { desc = "Move window to workspace " .. i })
end
create_bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { desc = "Next workspace" })
create_bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { desc = "Previous workspace" })

-- 5. Media
create_bind({ vars.kbMediaToggle, "XF86AudioPlay", "XF86AudioPause" }, hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true, desc = "Play / pause" })
create_bind({ vars.kbMediaNext, "XF86AudioNext" },   hl.dsp.exec_cmd(ipc .. "media next"), { locked = true, desc = "Next track" })
create_bind({ vars.kbMediaPrev, "XF86AudioPrev" },   hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true, desc = "Previous track" })
create_bind({ vars.kbMediaStop, "XF86AudioStop" },   hl.dsp.exec_cmd(ipc .. "media stop"), { locked = true, desc = "Stop media" })

-- 6. Brightness
create_bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd(ipc .. "brightness-up"), { locked = true, desc = "Brightness up" })
create_bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd(ipc .. "brightness-down"), { locked = true, desc = "Brightness down" })

-- 7. Volume
create_bind({ vars.kbVolumeMute, "XF86AudioMute" }, hl.dsp.exec_cmd(ipc .. "volume-mute"), { locked = true, desc = "Mute volume" })
create_bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "mic-mute"), { locked = true, desc = "Mute mic" })
create_bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), { locked = true, repeating = true, desc = "Volume up" })
create_bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), { locked = true, repeating = true, desc = "Volume down" })
create_bind(vars.kbAudioSettings, hl.dsp.exec_cmd(vars.audioSettings), { desc = "Audio settings" })

-- 8. Sleep
create_bind(vars.kbSleep, hl.dsp.exec_cmd(vars.sleepGestureCmd), { locked = true, desc = "Sleep" })
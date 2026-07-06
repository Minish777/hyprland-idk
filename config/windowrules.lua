-- Picture-in-Picture
hl.window_rule({
    match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float = true,
    keep_aspect_ratio = true,
    move = "73% 72%",
    size = "25% 25%",
    pin = true,
})

---------------------------------------------------
-- Gaming (ОЧИЩЕНО, БЕЗ WORKSPACE ПЕРЕНОСОВ)
---------------------------------------------------

local gamingApps = "^(steam_app.*|gamescope)$"

-- Steam Friends
hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^(Friends List)$"
    },
    float = true,
})

-- Steam launching popup
hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^(Launching\\.{3})$"
    },
    float = true,
    center = true,
})

-- Main games (fullscreen)
hl.window_rule({
    match = {
        class = gamingApps,
        title = "^.+$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    size = "monitor_w monitor_h",
    fullscreen_state = 2,
    content = "game",
})

-- Steam blank / preload windows
hl.window_rule({
    match = {
        class = "^(steam_app.*)$",
        initial_title = "^$",
    },
    float = true,
    center = true,
    fullscreen = false,
    fullscreen_state = 0,
})

---------------------------------------------------
-- Apps
---------------------------------------------------

local primaryWorkspace = 1

hl.window_rule({
    match = { class = "^(.*\\.exe)$" },
    float = true,
    center = true,
    fullscreen_state = 0
})

hl.window_rule({
    match = { class = "^(vesktop|discord)$" },
})

hl.window_rule({
    match = { class = "^(.*[Cc]alculator.*)$" },
    float = true,
    size = "380 616"
})

hl.window_rule({
    match = { class = "^(org.kde.keditfiletype)$" },
    float = true
})

hl.window_rule({
    match = { class = "^(org.kde.ark)$" },
    size = "(monitor_w*0.40) (monitor_h*0.40)"
})

hl.window_rule({
    match = {
        class = "^(org.kde.dolphin)$",
        title = "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
    },
    float = true,
    move = {
        "max(0, min(cursor_x - 650, monitor_w - 1320))",
        "max(0, min(cursor_y - 50, monitor_h - 820))"
    },
    size = "1300 800",
})

---------------------------------------------------
-- Opacity Overrides
---------------------------------------------------

local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"

hl.window_rule({ match = { class = "^(firefox|zen)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" })

hl.window_rule({
    match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" },
    opacity = "1.0 override"
})

---------------------------------------------------
-- Float Utility Windows
---------------------------------------------------

local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}

for _, m in ipairs(floatApps) do
    hl.window_rule({ match = m, float = true })
end

hl.window_rule({
    match = { float = true },
    move = "50% 50%"
})

---------------------------------------------------
-- Float Modals
---------------------------------------------------

local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$" },
}

for _, m in ipairs(modalMatches) do
    hl.window_rule({ match = m, float = true })
end

---------------------------------------------------
-- Anti-maximize spam
---------------------------------------------------

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

---------------------------------------------------
-- XWayland drag fix
---------------------------------------------------

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

---------------------------------------------------
-- NOCTALIA LAYERS
---------------------------------------------------

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})



---------------------------------------------------
-- AUTO GAMING MODE FOR ALL APPS
---------------------------------------------------

hl.window_rule({
    match = { fullscreen = true },
    border_size = 0,
    no_shadow = true,
    no_blur = true
})

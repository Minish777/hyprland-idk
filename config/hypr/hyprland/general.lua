local vars = require("variables")

hl.config({
    general = {
        layout          = "master",

        allow_tearing   = false, -- Allows `immediate` window rule to work

        gaps_workspaces = vars.workspaceGaps,
        gaps_in         = vars.windowGapsIn,
        gaps_out        = vars.windowGapsOut,
        border_size     = vars.windowBorderSize,

        col             = {
            active_border   = vars.activeWindowBorderColour,
            inactive_border = vars.inactiveWindowBorderColour,
        },
    },

    master = {
        mfact                 = 0.55, -- Master area ratio
        orientation           = "left", -- Master column on the left
        new_status            = "master", -- New windows become master
        new_on_active         = "slave", -- Steal focus with new window?
        new_on_top            = true,
        allow_small_split     = false,
        special_scale_factor  = 0.8, -- Special workspace scale
        slave_count_for_center_master = 2,
    },
})

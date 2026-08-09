-- Hyprland Lua config entry point.
-- Each module registers its own configuration when required.
-- Refer to the wiki for more information: https://wiki.hypr.land/Configuring/Start/

require("monitors")
require("env")
require("programs")
require("appearance")
require("animations")
require("input")
require("workspaces")

local autostart = require("autostart")
local binds = require("binds")
local window_rules = require("window_rules")

autostart.run()
binds.setup()
window_rules.setup()

-- Per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

-- Touchpad gestures
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

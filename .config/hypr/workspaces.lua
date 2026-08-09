-- Workspace → monitor assignments, alternating between the internal
-- display and the external one, matching hyprland.conf
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
local assignments = {
	{ "1", "eDP-1" }, { "2", "HDMI-A-1" }, { "3", "eDP-1" }, { "4", "HDMI-A-1" },
	{ "5", "eDP-1" }, { "6", "HDMI-A-1" }, { "7", "eDP-1" }, { "8", "HDMI-A-1" },
	{ "9", "eDP-1" }, { "10", "HDMI-A-1" },
}

for _, a in ipairs(assignments) do
	hl.workspace_rule({
		workspace = a[1],
		monitor = a[2],
		persistent = true,
		default = false,
	})
end

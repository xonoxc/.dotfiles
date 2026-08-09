-- autostart.lua
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

local M = {}

M.run = function()
	hl.on("hyprland.start", function()
		-- core system
		hl.exec_cmd("nm-applet")
		hl.exec_cmd("waybar")
		hl.exec_cmd("hyprctl setcursor Breeze_Light 20")
		hl.exec_cmd("swaync")
		hl.exec_cmd("/usr/lib/pam_kwallet_init")

		-- visuals
		hl.exec_cmd("swww-daemon")
		hl.exec_cmd("waytrogen --restore")

		-- clipboard (keep both, valid)
		hl.exec_cmd("wl-paste -p -t text --watch clipman store -P --histpath=~/.local/share/clipman-primary.json")
		hl.exec_cmd("wl-paste --type text --watch cliphist store")
		hl.exec_cmd("wl-paste --type image --watch cliphist store")

		-- system utils
		hl.exec_cmd("blueman-applet")
		hl.exec_cmd("hypridle")
		hl.exec_cmd("hyprsunset")
	end)
end

return M

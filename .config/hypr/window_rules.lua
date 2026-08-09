-- window_rules.lua

local M = {}

M.setup = function()
	-- terminal → ws1
	hl.window_rule({
		match = { class = "^kitty$" },
		workspace = "1",
	})

	-- browsers → ws2
	hl.window_rule({
		match = { class = "^helium$|^brave$" },
		workspace = "2",
	})

	-- notes → ws3
	hl.window_rule({
		match = { class = "^obsidian$" },
		workspace = "3",
	})

	-- file manager → ws4
	hl.window_rule({
		match = { class = "^thunar$" },
		workspace = "4",
	})

	-- floating dialogs (picture-in-picture, uploads, prints)
	hl.window_rule({
		match = { title = "Picture-in-Picture|File Upload|Print" },
		float = true,
	})

	-- floating system dialogs
	hl.window_rule({
		match = { class = "blueman-manager|nm-applet|pavucontrol" },
		float = true,
	})

	-- small gui tools
	hl.window_rule({
		match = { class = "^nwg-look$" },
		float = true,
	})

	-- dolphin progress dialog
	hl.window_rule({
		match = { class = "^org.kde.dolphin$", title = "^Progress Dialog — Dolphin$" },
		float = true,
	})

	-- firefox about / devtools
	hl.window_rule({
		match = { title = "^About Mozilla Firefox$" },
		float = true,
	})
	hl.window_rule({
		match = { class = "^firefox$", title = "^Developer Tools$" },
		float = true,
	})

	-- blueman manager fixed size
	hl.window_rule({
		match = { class = "^blueman-manager$" },
		size = { 800, 500 },
	})

	-- file upload fixed size
	hl.window_rule({
		match = { title = "^File Upload$" },
		size = { 800, 500 },
	})

	-- kde polkit agent
	hl.window_rule({
		match = { class = "^org.kde.polkit-kde-authentication-agent-1$" },
		float = true,
	})

	-- nm-connection-editor
	hl.window_rule({
		match = { class = "^nm-connection-editor$" },
		float = true,
	})

	-- ignore maximize requests from all apps
	hl.window_rule({
		match = { class = ".*" },
		suppress_event = "maximize",
	})

	-- scrcpy floating window
	hl.window_rule({
		match = { class = "^scrcpy$" },
		float = true,
		size = { 400, 900 },
		move = { 70, 70 },
	})

	-- xdg-desktop-portal-gtk
	hl.window_rule({
		match = { class = "^xdg-desktop-portal-gtk$" },
		float = true,
		size = { 800, 500 },
	})

	-- helium print window
	hl.window_rule({
		match = { class = "^helium$", title = "^Print$" },
		float = true,
		size = { 800, 500 },
	})

	-- mpv floating window
	hl.window_rule({
		match = { class = "^mpv$" },
		float = true,
	})
end

return M

-- window_rules.lua

local M = {}

M.setup = function()
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

	-- Google Meet screen-sharing indicator
	hl.window_rule({
		match = {
			title = "^meet%.google%.com is sharing a window%.$",
		},
		float = true,
		no_focus = true,
		move = { 10, 890 },
		border_size = 0,
	})

	-- Google Meet PiP
	hl.window_rule({
		match = {
			class = "^helium$",
			title = "^Meet – ",
		},
		float = true,
		no_focus = true,
		move = { 1250, 820 },
		border_size = 0,
	})

	-- swaync control center: slide in from the right edge
	-- (it's a layer, not a window, so hl.window_rule doesn't apply)
	hl.layer_rule({
		name = "swaync-cc-slide-right",
		match = { namespace = "swaync-control-center" },
		animation = "slide right",
	})

	-- swaync popup notifications: same slide-in from right / slide-out to right
	hl.layer_rule({
		name = "swaync-notif-slide-right",
		match = { namespace = "swaync-notification-window" },
		animation = "slide right",
	})

	-- Save this in your ~/.config/hypr/hyprland.lua (or rules submodule)
	hl.window_rule({
		name = "gimp-dialog-fix", -- Optional: Named rules can be dynamically toggled later
		match = {
			class = "^GIMP$",
			title = "^(Export Image|Save Image|Open Image)$",
		},
		float = true,
		size = { 800, 600 }, -- Takes a standard Lua table for width/height
		center = true,
	})

	hl.window_rule({
		name = "gimp-jpeg-export-fix",
		match = {
			class = "^GIMP$",
			title = "^Export Image as .*$", -- This wildcard catches JPEG, PNG, WebP, etc.
		},
		float = true,
		size = { 750, 480 }, -- Slightly shorter height to perfectly fit this specific tool layout
		center = true,
	})

	-- Force GIMP dialogs/popups to float
	hl.window_rule({
		name = "gimp-float",
		match = {
			class = "^(gimp.*)$",
		},
		float = true,
	})

	hl.window_rule({
		name = "gimp-splash-center",
		match = {
			class = "^(gimp.*)$",
			title = "^(GIMP Startup)$",
		},
		center = true,
	})

	-- Keep the main GIMP window tiled, but float all child dialogs
	hl.window_rule({
		name = "gimp-dialogs-float",
		match = {
			class = "^(gimp.*)$",
			float = true,
		},
		center = true,
		-- Cap the size of floating dialogs so GTK widgets don't stretch vertically
		size = { "<850", "<650" },
	})

	-- Specific rule for Export / Save / File dialogs if they still open too tall
	hl.window_rule({
		name = "gimp-export-dialog",
		match = {
			class = "^(gimp.*)$",
			title = "^(Export Image.*|Save Image.*|Open Image.*)$",
		},
		float = true,
		center = true,
		size = { 750, 580 },
	})
end

return M

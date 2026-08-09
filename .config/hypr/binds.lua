local p = require("programs")

local M = {}

local mainMod = "SUPER" -- modified key

M.setup = function()
	-- launch
	hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(p.terminal))
	hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(p.alt_terminal))

	hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(p.browser))
	hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(p.alt_browser))

	hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(p.file_manager))
	hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(p.menu))
	hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(p.window_menu))
	hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(p.emoji_menu))

	hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(p.notes))

	-- control
	hl.bind(mainMod .. " + Q", hl.dsp.window.close())
	hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
	hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float())

	-- notification center
	hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))

	-- system
	hl.bind(mainMod .. " + X", hl.dsp.exit())
	hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("reboot"))
	hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

	-- clipboard
	hl.bind(
		mainMod .. " + V",
		hl.dsp.exec_cmd("cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy")
	)

	-- focus
	hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
	hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
	hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
	hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

	-- cycle through windows
	hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())

	-- workspaces
	for i = 1, 10 do
		local key = i % 10 -- 10 maps to key 0
		-- Switch to workspace (SUPER + 0-9)
		hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
		-- Move active window to workspace (SUPER + SHIFT + 0-9)
		hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	end

	-- special workspace (scratchpad)
	hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
	hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

	-- scroll through existing workspaces with mainMod + scroll
	hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
	hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

	-- move/resize windows with mainMod + LMB/RMB and dragging
	hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
	hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

	-- resize windows with keyboard only
	hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
	hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))

	-- toggle waybar
	hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

	-- color picker
	hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))

	-- wallpaper picker
	hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("waytrogen"))

	-- screenshot tooling
	hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
	hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
	hl.bind(mainMod .. " + SHIFT + o", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))

	-- gamma via hyprsunset
	hl.bind(
		mainMod .. " + XF86MonBrightnessDown",
		hl.dsp.exec_cmd("hyprctl hyprsunset gamma -10"),
		{ locked = true, repeating = true }
	)
	hl.bind(
		mainMod .. " + XF86MonBrightnessUp",
		hl.dsp.exec_cmd("hyprctl hyprsunset gamma +10"),
		{ locked = true, repeating = true }
	)

	-- laptop multimedia keys for volume and LCD brightness
	hl.bind(
		"XF86AudioRaiseVolume",
		hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
		{ locked = true, repeating = true }
	)
	hl.bind(
		"XF86AudioLowerVolume",
		hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
		{ locked = true, repeating = true }
	)
	hl.bind(
		"XF86AudioMute",
		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
		{ locked = true, repeating = true }
	)
	hl.bind(
		"XF86AudioMicMute",
		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
		{ locked = true, repeating = true }
	)
	hl.bind(
		"XF86MonBrightnessUp",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
		{ locked = true, repeating = true }
	)
	hl.bind(
		"XF86MonBrightnessDown",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
		{ locked = true, repeating = true }
	)

	-- requires playerctl
	hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
	hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
	hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
	hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
end

return M

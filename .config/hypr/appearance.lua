hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 1,

		border_size = 2,

		col = {
			active_border = {
				colors = { "rgba(7f849ccc)", "rgba(9399b2cc)" },
				angle = 45,
			},
			inactive_border = {
				colors = { "rgba(585b7088)", "rgba(585b7088)" },
				angle = 45,
			},
		},

		resize_on_border = true,
		allow_tearing = false,

		layout = "dwindle",
	},
	decoration = {
		rounding = 3,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		blur = {
			enabled = false,
			size = 10,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
})

hl.config({
	cursor = {
		no_warps = false,
	},
})

hl.config({
	misc = {
		force_default_wallpaper = 1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
	},
})

hl.config({
	xwayland = {
		force_zero_scaling = false,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

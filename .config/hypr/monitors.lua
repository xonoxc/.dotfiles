-- Monitors config
--

-- internal display
-- the first and left side monitor is the internal display
hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@60",
	position = "0x0",
	scale = 1.25,
})

-- any monitor connected to this
-- goes on the right side of the internal display
hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@60",
	position = "0x1200",
	scale = 1,
})

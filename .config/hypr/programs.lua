-- all the programs that i use frequently

local M = {}

M.terminal = "kitty"
M.alt_terminal = "alacritty"

M.file_manager = "thunar"

M.browser = "helium-browser --enable-features=UseOzonePlatform --ozone-platform=wayland"
M.alt_browser = "brave --enable-features=UseOzonePlatform --ozone-platform=wayland"

M.menu = "rofi -show drun -theme ~/.config/rofi/config.rasi"
M.window_menu = "rofi -show window -theme ~/.config/rofi/config.rasi"
M.emoji_menu = "rofi -show emoji -theme ~/.config/rofi/config.rasi"

M.notes = "obsidian"

return M

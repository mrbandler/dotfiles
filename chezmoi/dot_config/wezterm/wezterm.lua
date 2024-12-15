local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Theme & Appearance
config.term = "wezterm"
config.font = wezterm.font_with_fallback { 'JetBrainsMono Nerd Font', 'JetBrains Mono' }
config.font_size = 12.0
config.line_height = 0.9
config.initial_rows = 60
config.initial_cols = 238
config.enable_scroll_bar = true
config.color_scheme = 'Catppuccin Macchiato (Gogh)'
config.enable_tab_bar = false
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '0',
  bottom = '1cell',
}
config.window_background_opacity = 0.9
config.default_cursor_style = 'BlinkingUnderline'
config.adjust_window_size_when_changing_font_size  = true

-- Actions
paste = wezterm.action_callback(function(window, pane)
  local has_selection = window:get_selection_text_for_pane(pane) ~= ""
  if has_selection then
    window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
    window:perform_action(act.ClearSelection, pane)
  else
    window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
  end
end)

-- Functionality
config.default_prog = { 'nu' }

-- Keybindings
config.leader = { key = 'Space', mods = 'CTRL|SHIFT' }
config.keys = {
  { key = 'V', mods = 'CTRL', action = paste },
  { key = 'V', mods = 'CTRL', action = paste },
}
-- Mousbindings
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = paste,
	},
}


return config

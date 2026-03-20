{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "terminals" "wezterm" ] [ "programs" "wezterm" ])
  ];

  config.programs.wezterm.extraConfig = ''
    config.window_close_confirmation = 'NeverPrompt'
    config.line_height = 0.9
    config.enable_scroll_bar = false
    config.enable_tab_bar = false
    config.hide_tab_bar_if_only_one_tab = true
    config.window_decorations = 'NONE'
    config.window_padding = {
      left = '0.5cell',
      right = '0.5cell',
      top = '0.5cell',
      bottom = '0.5cell',
    }
    config.default_cursor_style = 'BlinkingUnderline'
    config.font = wezterm.font('JetBrainsMono Nerd Font')
    config.adjust_window_size_when_changing_font_size = true
    config.default_prog = {"nu"}
  '';
}

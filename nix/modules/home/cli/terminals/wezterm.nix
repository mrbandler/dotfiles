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
  '';
}

{
  lib,
  pkgs,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "creative" "obs" ] [ "programs" "obs-studio" ])
  ];

  config.programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs # Screen capture for wlroots/Wayland compositors
    ];
  };
}

{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.apps.gaming;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "gaming" "mangohud" ] [ "programs" "mangohud" ])
  ];

  config.programs.mangohud = mkIf cfg.enable {
    enable = true;
    settings = mapAttrsRecursive (_: mkDefault) {
      fps_limit = 0;
      gpu_stats = true;
      gpu_temp = true;
      gpu_power = true;
      cpu_stats = true;
      cpu_temp = true;
      ram = true;
      vram = true;
      fps = true;
      frametime = true;
      frame_timing = true;
      font_size = 20;
      position = "top-left";
      toggle_hud = "Shift_R+F12";
      no_display = true; # hidden by default, toggle with keybind
    };
  };
}

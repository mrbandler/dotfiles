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

  config = mkIf cfg.enable {
    # MangoHud is available but not globally injected.
    # Use per-game: Steam launch options → "mangohud %command%"
    # Or wrap any game with: mangohud <command>

    programs.mangohud = {
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
      toggle_hud = "Scroll_Lock";
      no_display = true; # hidden by default, toggle with keybind
      };
    };
  };
}

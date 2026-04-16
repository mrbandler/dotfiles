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
    # Use per-game: gamemoderun mangohud %command%
    # Steam has MANGOHUD injected via extraEnv in the NixOS steam module.
    # Heroic/Lutris have built-in MangoHud toggles in their settings.

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
        toggle_hud = "Pause";
        no_display = true;
      };
    };
  };
}

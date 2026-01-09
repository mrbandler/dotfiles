{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.gaming.kernelTweaks;
  gamingCfg = config.${namespace}.desktop.services.gaming;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.services.gaming.kernelTweaks = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable kernel tweaks for gaming.";
    };
  };

  config = mkIf (desktopCfg.enable && gamingCfg.enable && cfg.enable) {
    boot.kernel.sysctl = {
      # Needed for some games (e.g., Star Citizen)
      "vm.max_map_count" = 2147483642;
    };
  };
}

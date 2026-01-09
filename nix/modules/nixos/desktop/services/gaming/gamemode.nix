{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.gaming.gamemode;
  gamingCfg = config.${namespace}.desktop.services.gaming;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.services.gaming.gamemode = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GameMode for performance optimization.";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "GameMode configuration.";
      example = literalExpression ''
        {
          general = {
            renice = 10;
          };
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
            amd_performance_level = "high";
          };
        }
      '';
    };
  };

  config = mkIf (desktopCfg.enable && gamingCfg.enable && cfg.enable) {
    programs.gamemode = {
      enable = true;
      settings = cfg.settings;
    };
  };
}

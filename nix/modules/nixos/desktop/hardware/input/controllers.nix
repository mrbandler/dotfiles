{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.input.controllers;
  gameCfg = config.${namespace}.desktop.services.gaming;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.input.controllers = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable game controller support.";
    };
  };

  config = mkIf (desktopCfg.enable && gameCfg.enable && cfg.enable) {
    hardware.xone.enable = true;
    hardware.xpadneo.enable = true;
  };
}

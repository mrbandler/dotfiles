{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.input.wacom;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.input.wacom = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Wacom tablet support.";
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    services.xserver.wacom.enable = true;
  };
}

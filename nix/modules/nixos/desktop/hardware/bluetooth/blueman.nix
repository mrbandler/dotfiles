{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.bluetooth.blueman;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.bluetooth.blueman = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Blueman GUI manager.";
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    services.blueman.enable = true;
  };
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  desktopCfg = config.${namespace}.desktop;
in
{
  config = mkIf desktopCfg.enable {
    hardware.i2c.enable = true;
  };
}

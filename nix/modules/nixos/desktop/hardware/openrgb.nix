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
    services.hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
  };
}

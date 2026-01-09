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
    # Common hardware configuration can go here
  };
}

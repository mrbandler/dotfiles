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
  imports = [
    ./displays.nix
    ./openrgb.nix
  ];

  config = mkIf desktopCfg.enable {
    # Common hardware configuration can go here
  };
}

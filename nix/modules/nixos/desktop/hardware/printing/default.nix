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
    ./cups.nix
    ./scanning.nix
  ];

  config = mkIf desktopCfg.enable {
    # Common configuration can go here if needed
  };
}

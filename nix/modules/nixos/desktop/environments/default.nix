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
    ./plasma.nix
    ./niri.nix
  ];

  config = mkIf desktopCfg.enable {
    # Common desktop environment configuration can go here
  };
}

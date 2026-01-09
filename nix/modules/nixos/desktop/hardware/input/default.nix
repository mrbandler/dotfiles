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
    ./touchpad.nix
    ./wacom.nix
    ./controllers.nix
  ];

  config = mkIf desktopCfg.enable {
    # Common input configuration can go here if needed
  };
}

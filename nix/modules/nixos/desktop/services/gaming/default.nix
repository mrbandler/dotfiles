{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.gaming;
  desktopCfg = config.${namespace}.desktop;
in
{
  imports = [
    ./steam.nix
    ./gamemode.nix
    ./kernel-tweaks.nix
  ];

  options.${namespace}.desktop.services.gaming = {
    enable = mkEnableOption "gaming services";
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # Enable 32-bit graphics for gaming
    hardware.graphics.enable32Bit = true;
  };
}

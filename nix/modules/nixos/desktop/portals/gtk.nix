{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.portals.gtk;
  portalsCfg = config.${namespace}.desktop.portals;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.portals.gtk = {
    enable = mkEnableOption "GTK portal support";
  };

  config = mkIf (desktopCfg.enable && portalsCfg.enable && cfg.enable) {
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}

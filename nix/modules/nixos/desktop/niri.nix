{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.niri = {
    enable = mkEnableOption "Niri window manager";

    panel = mkOption {
      type = types.enum [
        "waybar"
        "quickshell"
        "none"
      ];
      default = "waybar";
      description = "Status bar/panel to use with Niri";
    };
  };

  config = mkIf (cfg.enable && cfg.niri.enable) {
    programs.niri.enable = true;

    environment.systemPackages =
      with pkgs;
      [
        # Niri essentials
        niri

        # Panel/bar
      ]
      ++ optional (cfg.niri.panel == "waybar") waybar
      ++ optional (cfg.niri.panel == "quickshell") quickshell;

    # Essential portal support for Niri
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      config.niri = {
        default = [ "gtk" ];
      };
    };
  };
}

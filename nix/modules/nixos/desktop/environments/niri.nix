{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.environments.niri;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.environments.niri = {
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

  config = mkIf (desktopCfg.enable && cfg.enable) {
    programs.niri.enable = true;

    services.displayManager.sessionPackages = [ pkgs.niri ];

    environment.systemPackages =
      with pkgs;
      [
        niri
      ]
      ++ optional (cfg.panel == "waybar") waybar
      ++ optional (cfg.panel == "quickshell") quickshell;
  };
}

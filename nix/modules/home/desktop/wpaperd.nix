{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.desktop.wpaperd;
in
{
  options.internal.desktop.wpaperd = {
    enable = mkEnableOption "wpaperd wallpaper daemon";

    mode = mkOption {
      type = types.enum [ "center" "stretch" "fit" "tile" ];
      default = "center";
      description = ''
        How to display the wallpaper:
        - center: Center the image
        - stretch: Stretch to fill screen
        - fit: Fit within screen (maintain aspect ratio)
        - tile: Tile the image
      '';
    };

    monitors = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          path = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to wallpaper for this monitor. If null, uses Stylix image.";
          };

          mode = mkOption {
            type = types.nullOr (types.enum [ "center" "stretch" "fit" "tile" ]);
            default = null;
            description = "Display mode for this monitor. If null, uses global mode.";
          };
        };
      });
      default = {};
      example = literalExpression ''
        {
          eDP-1 = {
            path = ./wallpapers/laptop.png;
            mode = "fit";
          };
          HDMI-A-1 = {
            path = ./wallpapers/monitor.png;
            mode = "center";
          };
        }
      '';
      description = ''
        Per-monitor wallpaper configuration.
        If empty, uses default configuration with Stylix image.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.wpaperd = {
      enable = true;
      settings =
        if cfg.monitors == {} then
          # Default configuration: use Stylix image
          {
            default = {
              path = config.stylix.image;
              mode = cfg.mode;
            };
          }
        else
          # Per-monitor configuration
          mapAttrs (name: monitorCfg: {
            path = if monitorCfg.path != null then monitorCfg.path else config.stylix.image;
            mode = if monitorCfg.mode != null then monitorCfg.mode else cfg.mode;
          }) cfg.monitors;
    };
  };
}

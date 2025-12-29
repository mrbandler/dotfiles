{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.portals;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.portals = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable XDG desktop portals.";
    };

    extraPortals = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional portal implementations to install.";
      example = literalExpression ''
        with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ]
      '';
    };

    wlr = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable wlroots portal for screen sharing on wlroots-based compositors.";
      };

      settings = mkOption {
        type = types.attrs;
        default = { };
        description = "Configuration for xdg-desktop-portal-wlr.";
        example = literalExpression ''
          {
            screencast = {
              max_fps = 30;
              chooser_type = "simple";
              chooser_cmd = "''${pkgs.slurp}/bin/slurp -f %o -or";
            };
          }
        '';
      };
    };

    gtk = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable GTK portal for file chooser and other GTK-based dialogs.";
      };
    };

    config = mkOption {
      type = types.attrs;
      default = { };
      description = "Portal configuration mapping desktop environments to portal implementations.";
      example = literalExpression ''
        {
          common = {
            default = [ "gtk" ];
          };
          niri = {
            default = [ "gnome" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        }
      '';
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    xdg.portal = {
      enable = true;

      extraPortals =
        cfg.extraPortals
        ++ optional cfg.wlr.enable pkgs.xdg-desktop-portal-wlr
        ++ optional cfg.gtk.enable pkgs.xdg-desktop-portal-gtk;

      config = cfg.config;

      xdgOpenUsePortal = true;
    };

    # wlr portal configuration
    environment.etc."xdg-desktop-portal-wlr/config" = mkIf (cfg.wlr.enable && cfg.wlr.settings != { }) {
      text = generators.toINI { } cfg.wlr.settings;
    };
  };
}

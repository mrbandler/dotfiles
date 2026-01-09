{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.portals;
  desktopCfg = config.${namespace}.desktop;
in
{
  imports = [
    ./gtk.nix
    ./wlr.nix
  ];

  options.${namespace}.desktop.portals = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable XDG desktop portals support.";
    };

    extraPortals = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional portal implementations to install.";
      example = literalExpression ''
        with pkgs; [
          xdg-desktop-portal-gnome
        ]
      '';
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

    xdgOpenUsePortal = mkOption {
      type = types.bool;
      default = true;
      description = "Use portals for xdg-open.";
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    xdg.portal = {
      enable = true;
      extraPortals = cfg.extraPortals;
      config = cfg.config;
      xdgOpenUsePortal = cfg.xdgOpenUsePortal;
    };
  };
}

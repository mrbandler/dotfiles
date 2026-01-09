{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.managers.sddm;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.managers.sddm = {
    enable = mkEnableOption "SDDM display manager";

    wayland = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland support for SDDM.";
    };

    theme = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SDDM theme to use.";
    };

    themePackage = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "SDDM theme package to install.";
      example = literalExpression ''
        pkgs.catppuccin-sddm.override {
          background = "''${pkgs.internal.wallpapers}/share/wallpapers/12-5/mocha-3840x1600.png";
          loginBackground = true;
        }
      '';
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    environment.systemPackages = optional (cfg.themePackage != null) cfg.themePackage;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = cfg.wayland;
    }
    // optionalAttrs (cfg.theme != null) {
      theme = cfg.theme;
    };
  };
}

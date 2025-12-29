{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.sddm = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SDDM display manager.";
    };

    wayland = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland support for SDDM.";
    };

    theme = mkOption {
      type = types.str;
      default = "catppuccin-mocha-mauve";
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

  config = mkIf (cfg.enable && cfg.sddm.enable) {
    environment.systemPackages = optional (cfg.sddm.themePackage != null) cfg.sddm.themePackage;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = cfg.sddm.wayland;
      theme = cfg.sddm.theme;
    };
  };
}

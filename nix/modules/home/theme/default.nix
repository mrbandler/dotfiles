{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.theme;
in
{
  options.internal.theme = {
    enable = mkEnableOption "user theme with Stylix";

    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = literalExpression "./wallpapers/my-wallpaper.png";
      description = ''
        Path to wallpaper image.
        Used as desktop background and can generate color scheme if not explicitly set.
      '';
    };

    colorScheme = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "catppuccin-mocha";
      description = ''
        Base16 color scheme name to use.
        Popular schemes: catppuccin-mocha, gruvbox-dark-hard, nord, tokyo-night-dark, one-light.
        If null, colors will be automatically generated from the wallpaper.
      '';
    };

    polarity = mkOption {
      type = types.nullOr (
        types.enum [
          "light"
          "dark"
        ]
      );
      default = "dark";
      description = ''
        Force light or dark theme.
        If null, polarity is automatically determined from the color scheme.
      '';
    };

    fonts = {
      sizes = {
        applications = mkOption {
          type = types.int;
          default = 12;
          description = "Font size for applications (in points).";
        };

        terminal = mkOption {
          type = types.int;
          default = 12;
          description = "Font size for terminals (in points).";
        };

        desktop = mkOption {
          type = types.int;
          default = 10;
          description = "Font size for desktop environment (in points).";
        };

        popups = mkOption {
          type = types.int;
          default = 10;
          description = "Font size for popups and tooltips (in points).";
        };
      };
    };

    cursor = {
      package = mkOption {
        type = types.package;
        default = pkgs.bibata-cursors;
        description = "Cursor theme package.";
      };

      name = mkOption {
        type = types.str;
        default = "Bibata-Modern-Classic";
        description = "Cursor theme name.";
      };

      size = mkOption {
        type = types.int;
        default = 24;
        description = "Cursor size (in pixels).";
      };
    };

    opacity = {
      applications = mkOption {
        type = types.float;
        default = 1.0;
        description = "Opacity for application windows (0.0-1.0).";
      };

      terminal = mkOption {
        type = types.float;
        default = 0.95;
        description = "Opacity for terminal windows (0.0-1.0).";
      };

      desktop = mkOption {
        type = types.float;
        default = 1.0;
        description = "Opacity for desktop environment elements (0.0-1.0).";
      };

      popups = mkOption {
        type = types.float;
        default = 1.0;
        description = "Opacity for popups and menus (0.0-1.0).";
      };
    };
  };

  config = mkIf cfg.enable {
    stylix = mkMerge [
      {
        enable = true;

        fonts.sizes = {
          applications = cfg.fonts.sizes.applications;
          terminal = cfg.fonts.sizes.terminal;
          desktop = cfg.fonts.sizes.desktop;
          popups = cfg.fonts.sizes.popups;
        };

        cursor = {
          package = cfg.cursor.package;
          name = cfg.cursor.name;
          size = cfg.cursor.size;
        };

        opacity = {
          applications = cfg.opacity.applications;
          terminal = cfg.opacity.terminal;
          desktop = cfg.opacity.desktop;
          popups = cfg.opacity.popups;
        };
      }

      (optionalAttrs (cfg.wallpaper != null) {
        image = cfg.wallpaper;
      })
      (optionalAttrs (cfg.colorScheme != null) {
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
      })
      (optionalAttrs (cfg.polarity != null) {
        polarity = cfg.polarity;
      })
    ];

    warnings = mkIf (cfg.wallpaper == null && cfg.colorScheme == null) [
      "theming: Neither wallpaper nor color scheme is set. Stylix may not function correctly."
    ];
  };
}

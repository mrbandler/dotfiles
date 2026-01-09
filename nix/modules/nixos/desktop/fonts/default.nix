{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.fonts;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.fonts = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable comprehensive font configuration.";
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        inter
        roboto
        jetbrains-mono
        fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.meslo-lg
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
        corefonts
        vista-fonts
      ];
      description = "Font packages to install.";
    };

    defaults = {
      serif = mkOption {
        type = types.listOf types.str;
        default = [
          "Liberation Serif"
          "DejaVu Serif"
        ];
        description = "Default serif fonts.";
      };

      sansSerif = mkOption {
        type = types.listOf types.str;
        default = [
          "Inter"
          "Roboto"
          "Liberation Sans"
          "DejaVu Sans"
        ];
        description = "Default sans-serif fonts.";
      };

      monospace = mkOption {
        type = types.listOf types.str;
        default = [
          "JetBrainsMono Nerd Font"
          "JetBrains Mono"
          "Fira Code"
        ];
        description = "Default monospace fonts.";
      };

      emoji = mkOption {
        type = types.listOf types.str;
        default = [ "Noto Color Emoji" ];
        description = "Default emoji fonts.";
      };
    };

    enableDefaultPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Install the default font packages.";
    };

    fontconfig = {
      antialias = mkOption {
        type = types.bool;
        default = true;
        description = "Enable font antialiasing.";
      };

      hinting = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable font hinting.";
        };

        style = mkOption {
          type = types.str;
          default = "slight";
          description = "Hinting style: none, slight, medium, full.";
        };
      };

      subpixel = {
        rgba = mkOption {
          type = types.str;
          default = "rgb";
          description = "Subpixel rendering order: rgb, bgr, vrgb, vbgr, none.";
        };

        lcdfilter = mkOption {
          type = types.str;
          default = "default";
          description = "LCD filter: default, light, legacy, none.";
        };
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    fonts = {
      packages = mkIf cfg.enableDefaultPackages cfg.packages;

      enableDefaultPackages = false; # We manage packages explicitly

      fontconfig = {
        enable = true;
        antialias = cfg.fontconfig.antialias;

        hinting = {
          enable = cfg.fontconfig.hinting.enable;
          style = cfg.fontconfig.hinting.style;
        };

        subpixel = {
          rgba = cfg.fontconfig.subpixel.rgba;
          lcdfilter = cfg.fontconfig.subpixel.lcdfilter;
        };

        defaultFonts = {
          serif = cfg.defaults.serif;
          sansSerif = cfg.defaults.sansSerif;
          monospace = cfg.defaults.monospace;
          emoji = cfg.defaults.emoji;
        };
      };
    };
  };
}

{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.gaming;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.gaming = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable gaming support.";
    };

    steam = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Steam.";
      };

      remotePlay = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Steam Remote Play.";
      };

      dedicatedServer = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Steam Dedicated Server.";
      };

      gamescopeSession = mkOption {
        type = types.bool;
        default = false;
        description = "Enable gamescope session for Steam.";
      };
    };

    gamemode = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable GameMode for performance optimization.";
      };

      settings = mkOption {
        type = types.attrs;
        default = { };
        description = "GameMode configuration.";
        example = literalExpression ''
          {
            general = {
              renice = 10;
            };
            gpu = {
              apply_gpu_optimisations = "accept-responsibility";
              gpu_device = 0;
              amd_performance_level = "high";
            };
          }
        '';
      };
    };

    mangohud = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable MangoHud overlay.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.mangohud;
        description = "MangoHud package to use.";
      };
    };

    gamescope = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Gamescope compositor.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.gamescope;
        description = "Gamescope package to use.";
      };
    };

    proton = {
      enableGE = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Proton-GE for improved game compatibility.";
      };
    };

    lutris = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Lutris game launcher.";
      };
    };

    wine = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Wine for running Windows games.";
      };

      package = mkOption {
        type = types.enum [
          "wine"
          "wine-staging"
          "wine-wayland"
        ];
        default = "wine-staging";
        description = "Wine package variant to use.";
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # Steam
    programs.steam = mkIf cfg.steam.enable {
      enable = true;
      remotePlay.openFirewall = cfg.steam.remotePlay;
      dedicatedServer.openFirewall = cfg.steam.dedicatedServer;
      gamescopeSession.enable = cfg.steam.gamescopeSession;
      extraCompatPackages = mkIf cfg.proton.enableGE [ pkgs.proton-ge-bin ];
    };

    # GameMode
    programs.gamemode = mkIf cfg.gamemode.enable {
      enable = true;
      settings = cfg.gamemode.settings;
    };

    # MangoHud and gaming packages
    environment.systemPackages =
      with pkgs;
      [ ]
      ++ optional cfg.mangohud.enable cfg.mangohud.package
      ++ optional cfg.gamescope.enable cfg.gamescope.package
      ++ optional cfg.lutris.enable lutris
      ++ optional (cfg.wine.enable && cfg.wine.package == "wine") wine
      ++ optional (cfg.wine.enable && cfg.wine.package == "wine-staging") wineWowPackages.staging
      ++ optional (cfg.wine.enable && cfg.wine.package == "wine-wayland") wineWowPackages.waylandFull;

    # Enable 32-bit graphics for gaming
    hardware.graphics.enable32Bit = mkIf cfg.steam.enable true;

    # Optimize kernel for gaming
    boot.kernel.sysctl = mkIf cfg.gamemode.enable {
      "vm.max_map_count" = 2147483642; # Needed for some games
    };
  };
}

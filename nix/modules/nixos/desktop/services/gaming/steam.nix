{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.gaming.steam;
  gamingCfg = config.${namespace}.desktop.services.gaming;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.services.gaming.steam = {
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

    protonGE = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Proton-GE for improved game compatibility.";
    };
  };

  config = mkIf (desktopCfg.enable && gamingCfg.enable && cfg.enable) {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = cfg.remotePlay;
      dedicatedServer.openFirewall = cfg.dedicatedServer;
      gamescopeSession.enable = cfg.gamescopeSession;
      extraCompatPackages = mkIf cfg.protonGE [ pkgs.proton-ge-bin ];
    };
  };
}

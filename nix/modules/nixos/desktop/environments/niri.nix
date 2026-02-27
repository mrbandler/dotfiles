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
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    programs.niri.enable = true;

    # Polkit is handled by DMS.
    systemd.user.services.niri-flake-polkit.enable = false;
    services.displayManager.sessionPackages = [ pkgs.niri ];

    environment.systemPackages =
      with pkgs;
      [
        niri
      ];
  };
}

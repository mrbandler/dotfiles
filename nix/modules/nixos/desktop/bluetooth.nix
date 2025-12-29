{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.bluetooth;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.bluetooth = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Bluetooth support.";
    };

    powerOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Power on Bluetooth adapters on boot.";
    };

    gui = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Bluetooth GUI manager (blueman).";
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.powerOnBoot;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    # Enable blueman for GUI management
    services.blueman.enable = mkIf cfg.gui true;

    # Ensure bluetooth service is enabled
    systemd.services.bluetooth.wantedBy = [ "multi-user.target" ];
  };
}

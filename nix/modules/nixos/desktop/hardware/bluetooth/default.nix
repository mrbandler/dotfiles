{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.bluetooth;
  desktopCfg = config.${namespace}.desktop;
in
{
  imports = [
    ./blueman.nix
  ];

  options.${namespace}.desktop.hardware.bluetooth = {
    powerOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Power on Bluetooth adapters on boot.";
    };

    experimental = mkOption {
      type = types.bool;
      default = true;
      description = "Enable experimental Bluetooth features.";
    };
  };

  config = mkIf desktopCfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.powerOnBoot;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = cfg.experimental;
        };
      };
    };

    systemd.services.bluetooth.wantedBy = [ "multi-user.target" ];
  };
}

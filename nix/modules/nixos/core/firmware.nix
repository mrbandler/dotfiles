{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.firmware = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable firmware updates via fwupd.";
    };

    enableTestRemotes = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable testing firmware remotes (LVFS testing).
        May be needed for some hardware (e.g., Intel CPUs) where even stable
        BIOS versions are marked as test versions in LVFS.
      '';
    };

    autoUpdate = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Automatically download and install firmware updates.
        Disabled by default - manual updates via 'fwupdmgr update' are recommended
        to avoid unexpected reboots or hardware issues.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Enable fwupd for firmware updates
    services.fwupd = {
      enable = cfg.firmware.enable;

      # Enable testing remotes if requested
      extraRemotes = mkIf cfg.firmware.enableTestRemotes [ "lvfs-testing" ];
    };

    # Automatic firmware updates (disabled by default for safety)
    # Users should manually run: sudo fwupdmgr refresh && sudo fwupdmgr update
    systemd.services.fwupd-auto-update = mkIf (cfg.firmware.enable && cfg.firmware.autoUpdate) {
      description = "Automatic firmware updates via fwupd";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${config.services.fwupd.package}/bin/fwupdmgr update --no-reboot-check --assume-yes";
      };
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.timers.fwupd-auto-update = mkIf (cfg.firmware.enable && cfg.firmware.autoUpdate) {
      description = "Timer for automatic firmware updates";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };
  };
}

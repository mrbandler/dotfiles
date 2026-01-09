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
  options.${namespace}.core.services = {
    fwupd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable firmware update daemon for automatic hardware firmware updates.";
      };
    };

    thermald = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable thermal daemon for CPU temperature management. Primarily useful for Intel CPUs.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Firmware updates
    services.fwupd.enable = cfg.services.fwupd.enable;

    # Thermal management (useful for Intel, harmless on AMD)
    services.thermald.enable = cfg.services.thermald.enable;
  };
}

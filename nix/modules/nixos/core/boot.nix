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
  options.${namespace}.core.boot = {
    loader = {
      systemd-boot = {
        configurationLimit = mkOption {
          type = types.int;
          default = 5;
          description = "Max boot entries to keep.";
        };
      };

      timeout = mkOption {
        type = types.int;
        default = 3;
        description = "Boot menu timeout in seconds.";
      };
    };

    consoleLogLevel = mkOption {
      type = types.int;
      default = 4;
      description = "Kernel console log level (0-7, lower = less verbose).";
    };

    kernelParams = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Kernel command line parameters.";
    };

    tmp = {
      useTmpfs = mkOption {
        type = types.bool;
        default = true;
        description = "Use tmpfs (RAM) for /tmp for better performance and reduced disk wear.";
      };
      cleanOnBoot = mkOption {
        type = types.bool;
        default = true;
        description = "Clear /tmp on boot (automatic when useTmpfs is true).";
      };
      nixTmpdir = mkOption {
        type = types.bool;
        default = true;
        description = "Use /var/tmp for Nix builds to prevent large builds from exhausting RAM.";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        efi.canTouchEfiVariables = mkDefault true;
        systemd-boot = {
          enable = true;
          configurationLimit = cfg.boot.loader.systemd-boot.configurationLimit;
          editor = mkDefault false;
        };
        timeout = cfg.boot.loader.timeout;
      };

      consoleLogLevel = cfg.boot.consoleLogLevel;
      kernelParams = cfg.boot.kernelParams;

      tmp = {
        useTmpfs = cfg.boot.tmp.useTmpfs;
        cleanOnBoot = cfg.boot.tmp.cleanOnBoot;
      };
    };

    # Redirect Nix daemon to use /var/tmp for large builds
    systemd.services.nix-daemon.environment = mkIf cfg.boot.tmp.nixTmpdir {
      TMPDIR = "/var/tmp";
    };
  };
}

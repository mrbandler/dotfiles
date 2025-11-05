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

    plymouth = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Plymouth boot splash.";
      };
      theme = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Plymouth theme name.";
      };
    };

    kernelParams = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Kernel command line parameters.";
    };

    tmp = {
      useTmpfs = mkOption {
        type = types.bool;
        default = false;
        description = "Use tmpfs for /tmp.";
      };
      cleanOnBoot = mkOption {
        type = types.bool;
        default = true;
        description = "Clear /tmp on boot.";
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

      plymouth = {
        enable = cfg.boot.plymouth.enable;
      }
      // optionalAttrs (cfg.boot.plymouth.theme != null) {
        theme = cfg.boot.plymouth.theme;
      };

      tmp = {
        useTmpfs = cfg.boot.tmp.useTmpfs;
        cleanOnBoot = cfg.boot.tmp.cleanOnBoot;
      };
    };
  };
}

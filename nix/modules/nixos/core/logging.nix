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
  options.${namespace}.core.logging = {
    journald = {
      storage = mkOption {
        type = types.enum [
          "auto"
          "persistent"
          "volatile"
          "none"
        ];
        default = "persistent";
        description = ''
          Where to store journal files.
          - persistent: Store in /var/log/journal (survives reboots)
          - volatile: Store in /run/log/journal (RAM only, cleared on reboot)
          - auto: Use persistent if /var/log/journal exists
          - none: Disable journald storage
        '';
      };

      maxRetentionSec = mkOption {
        type = types.str;
        default = "1month";
        description = ''
          Maximum time to keep journal entries.
          Examples: "1week", "1month", "3months", "1year"
        '';
      };

      maxFileSizeMiB = mkOption {
        type = types.int;
        default = 128;
        description = ''
          Maximum size of individual journal files in MiB.
          Journal will be rotated when this size is reached.
        '';
      };

      systemMaxUseMiB = mkOption {
        type = types.nullOr types.int;
        default = 512;
        description = ''
          Maximum total disk space journal can use in MiB.
          Set to null to disable limit (use 10% of filesystem by default).
        '';
      };

      rateLimit = {
        burst = mkOption {
          type = types.int;
          default = 10000;
          description = ''
            Maximum number of messages per interval before rate limiting kicks in.
            Default is 10000 messages per 30 seconds per service.
            Set to 0 to disable rate limiting (not recommended).
          '';
        };

        interval = mkOption {
          type = types.str;
          default = "30s";
          description = ''
            Time interval for rate limiting.
            Examples: "30s", "1min", "5min"
          '';
        };
      };

      forwardToSyslog = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Forward journal entries to syslog.
          Usually not needed on modern systems using journald.
        '';
      };

      userJournalAccess = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Allow users in the systemd-journal group to read system logs.
          Useful for debugging and monitoring.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    # Journald configuration
    services.journald.extraConfig = ''
      Storage=${cfg.logging.journald.storage}
      MaxRetentionSec=${cfg.logging.journald.maxRetentionSec}
      MaxFileSizeMiB=${toString cfg.logging.journald.maxFileSizeMiB}
      ${optionalString (
        cfg.logging.journald.systemMaxUseMiB != null
      ) "SystemMaxUse=${toString cfg.logging.journald.systemMaxUseMiB}M"}
      RateLimitBurst=${toString cfg.logging.journald.rateLimit.burst}
      RateLimitInterval=${cfg.logging.journald.rateLimit.interval}
      ForwardToSyslog=${if cfg.logging.journald.forwardToSyslog then "yes" else "no"}
    '';

    # Add primary user to systemd-journal group for log access
    users.users.${cfg.user.name}.extraGroups = mkIf cfg.logging.journald.userJournalAccess [
      "systemd-journal"
    ];
  };
}

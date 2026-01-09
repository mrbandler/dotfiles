{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.boot = {
    plymouth = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable Plymouth boot splash screen.
          Provides a graphical boot screen instead of text output.
          Disabled by default for faster boot times.
        '';
      };

      theme = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Plymouth theme name.";
      };
    };

    silent = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable silent boot - hide kernel messages during boot.
        Only shows Plymouth splash screen (if enabled) or minimal output.
        Recommended to enable Plymouth for a clean boot experience.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot = mkMerge [
      # Plymouth configuration
      (mkIf cfg.boot.plymouth.enable (
        {
          plymouth.enable = true;
        }
        // optionalAttrs (cfg.boot.plymouth.theme != null) {
          plymouth.theme = cfg.boot.plymouth.theme;
        }
      ))

      # Silent boot configuration
      (mkIf cfg.boot.silent {
        consoleLogLevel = mkDefault 3;
        initrd.verbose = mkDefault false;

        kernelParams = mkDefault (
          [
            "quiet"
            "udev.log_priority=3"
            "rd.udev.log_priority=3"
          ]
          ++ optional cfg.boot.plymouth.enable "splash"
        );
      })
    ];
  };
}

{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.printing;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.printing = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable printing support (CUPS).";
    };

    drivers = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional printer drivers to install.";
      example = literalExpression ''
        with pkgs; [
          gutenprint
          hplip
          epson-escpr
        ]
      '';
    };

    scanning = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable scanner support (SANE).";
      };

      extraBackends = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Additional scanner backends.";
        example = literalExpression ''
          with pkgs; [
            sane-airscan
            hplipWithPlugin
          ]
        '';
      };
    };

    avahi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable network printer discovery via Avahi.";
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # CUPS printing
    services.printing = {
      enable = true;
      drivers = cfg.drivers;
    };

    # Avahi for network printer discovery
    services.avahi = mkIf cfg.avahi {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Scanner support
    hardware.sane = mkIf cfg.scanning.enable {
      enable = true;
      extraBackends = cfg.scanning.extraBackends;
    };

    # Add scanner group for users
    users.groups.scanner = mkIf cfg.scanning.enable { };
  };
}

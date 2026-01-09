{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.printing.cups;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.printing.cups = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable CUPS printing service.";
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
  };
}

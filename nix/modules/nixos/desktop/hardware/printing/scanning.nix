{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.printing.scanning;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.printing.scanning = {
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

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # Scanner support
    hardware.sane = {
      enable = true;
      extraBackends = cfg.extraBackends;
    };

    # Add scanner group for users
    users.groups.scanner = { };
  };
}

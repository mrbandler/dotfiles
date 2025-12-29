{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.plasma = {
    enable = mkEnableOption "KDE Plasma desktop environment";

    excludePackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Plasma packages to exclude from installation";
      example = literalExpression ''
        with pkgs.kdePackages; [
          elisa
          gwenview
          okular
        ]
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.plasma.enable) {
    services.desktopManager.plasma6 = {
      enable = true;
    };

    environment.plasma6.excludePackages = cfg.plasma.excludePackages;

    # Plasma-specific portal configuration
    xdg.portal = {
      extraPortals = with pkgs; [
      ];
      config.plasma = {
        default = [ "kde" ];
      };
    };
  };
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.environments.plasma;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.environments.plasma = {
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

  config = mkIf (desktopCfg.enable && cfg.enable) {
    services.desktopManager.plasma6 = {
      enable = true;
    };

    environment.plasma6.excludePackages = cfg.excludePackages;
  };
}

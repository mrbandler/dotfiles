{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.portals.wlr;
  portalsCfg = config.${namespace}.desktop.portals;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.portals.wlr = {
    enable = mkEnableOption "wlroots portal support";

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Configuration for xdg-desktop-portal-wlr.";
      example = literalExpression ''
        {
          screencast = {
            max_fps = 30;
            chooser_type = "simple";
            chooser_cmd = "''${pkgs.slurp}/bin/slurp -f %o -or";
          };
        }
      '';
    };
  };

  config = mkIf (desktopCfg.enable && portalsCfg.enable && cfg.enable) {
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];

    environment.etc."xdg-desktop-portal-wlr/config" = mkIf (cfg.settings != { }) {
      text = generators.toINI { } cfg.settings;
    };
  };
}

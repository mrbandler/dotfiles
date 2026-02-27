{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.managers.dms;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.managers.dms = {
    enable = mkEnableOption "DMS greeter";

    compositor = mkOption {
      type = types.str;
      default = "niri";
      description = "Compositor to use.";
    };

    configHome = mkOption {
      type = types.str;
      default = "";
      description = "Home directory to use for configuration files.";
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = cfg.compositor;
      configHome = cfg.configHome;
    };
  };
}

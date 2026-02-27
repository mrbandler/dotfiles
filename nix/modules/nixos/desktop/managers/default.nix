{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.managers;
  desktopCfg = config.${namespace}.desktop;
in
{
  imports = [
    ./sddm.nix
    ./dms.nix
  ];

  options.${namespace}.desktop.managers = {
    defaultSession = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default desktop session.";
      example = "plasma";
    };
  };

  config = mkIf desktopCfg.enable {
    services.displayManager = {
      defaultSession = mkIf (cfg.defaultSession != null) cfg.defaultSession;
    };
  };
}

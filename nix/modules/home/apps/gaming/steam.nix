{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.apps.gaming.steam;
  gamingCfg = config.internal.apps.gaming;
in
{
  options.internal.apps.gaming.steam = {
    autostart = mkOption {
      type = types.bool;
      default = true;
      description = "Start Steam silently on login.";
    };
  };

  config = mkIf (gamingCfg.enable && cfg.autostart) {
    internal.desktop.core.init.spawn = [
      [ "steam" "-silent" ]
    ];
  };
}

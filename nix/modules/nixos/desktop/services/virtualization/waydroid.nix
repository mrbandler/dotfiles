{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.virtualization.waydroid;
  virtCfg = config.${namespace}.desktop.services.virtualization;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.services.virtualization.waydroid = {
    enable = mkEnableOption "Waydroid (Android container)";
  };

  config = mkIf (desktopCfg.enable && virtCfg.enable && cfg.enable) {
    virtualisation.waydroid.enable = true;
  };
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.virtualization.podman;
  virtCfg = config.${namespace}.desktop.services.virtualization;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.services.virtualization.podman = {
    enable = mkEnableOption "Podman";

    dockerCompat = mkOption {
      type = types.bool;
      default = true;
      description = "Create docker alias for podman.";
    };

    nvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA GPU support in Podman.";
    };
  };

  config = mkIf (desktopCfg.enable && virtCfg.enable && cfg.enable) {
    virtualisation.podman = {
      enable = true;
      dockerCompat = cfg.dockerCompat;
      defaultNetwork.settings.dns_enabled = true;
      enableNvidia = cfg.nvidia;
    };
  };
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.virtualization.docker;
  virtCfg = config.${namespace}.desktop.services.virtualization;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.services.virtualization.docker = {
    enable = mkEnableOption "Docker";

    rootless = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable rootless Docker.";
      };

      setSocketVariable = mkOption {
        type = types.bool;
        default = true;
        description = "Set DOCKER_HOST environment variable.";
      };
    };

    nvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA GPU support in Docker.";
    };

    storageDriver = mkOption {
      type = types.nullOr (
        types.enum [
          "overlay2"
          "btrfs"
          "zfs"
        ]
      );
      default = null;
      description = "Docker storage driver.";
    };
  };

  config = mkIf (desktopCfg.enable && virtCfg.enable && cfg.enable) {
    virtualisation.docker = {
      enable = true;
      rootless = mkIf cfg.rootless.enable {
        enable = true;
        setSocketVariable = cfg.rootless.setSocketVariable;
      };
      enableNvidia = cfg.nvidia;
      storageDriver = mkIf (cfg.storageDriver != null) cfg.storageDriver;
    };

    users.groups.docker = { };
    users.users.${config.${namespace}.core.user.name}.extraGroups = [ "docker" ];
  };
}

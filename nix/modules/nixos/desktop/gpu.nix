{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.gpu = {
    earlyKMS = mkOption {
      type = types.bool;
      default = true;
      description = "Enable early Kernel Mode Setting to avoid boot flickering.";
    };

    nvidia = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA GPU support.";
      };

      open = mkOption {
        type = types.bool;
        default = false;
        description = "Use open-source NVIDIA kernel modules (Turing/RTX 20+ series only).";
      };

      package = mkOption {
        type = types.package;
        default = config.boot.kernelPackages.nvidiaPackages.stable;
        description = "NVIDIA driver package to use.";
        example = literalExpression "config.boot.kernelPackages.nvidiaPackages.beta";
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    boot.initrd.kernelModules = mkIf cfg.gpu.earlyKMS (
      [
        "amdgpu"
        "i915"
      ]
      ++ optional cfg.gpu.nvidia.enable "nvidia"
      ++ optional cfg.gpu.nvidia.enable "nvidia_modeset"
      ++ optional cfg.gpu.nvidia.enable "nvidia_uvm"
      ++ optional cfg.gpu.nvidia.enable "nvidia_drm"
    );

    services.xserver.videoDrivers = mkIf cfg.gpu.nvidia.enable [ "nvidia" ];
    hardware.nvidia = mkIf cfg.gpu.nvidia.enable {
      modesetting.enable = true;
      open = cfg.gpu.nvidia.open;
      nvidiaSettings = false;
      package = cfg.gpu.nvidia.package;
    };
  };
}

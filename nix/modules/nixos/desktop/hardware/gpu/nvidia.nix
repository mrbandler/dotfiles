{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.gpu.nvidia;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.gpu.nvidia = {
    enable = mkEnableOption "NVIDIA GPU support";

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

    prime = {
      enable = mkEnableOption "NVIDIA Prime for hybrid graphics";

      offload = {
        enable = mkEnableOption "Prime offload mode";

        enableOffloadCmd = mkOption {
          type = types.bool;
          default = true;
          description = "Provide nvidia-offload command.";
        };
      };

      sync.enable = mkEnableOption "Prime sync mode";

      nvidiaBusId = mkOption {
        type = types.str;
        default = "";
        description = "Bus ID of the NVIDIA GPU.";
        example = "PCI:1:0:0";
      };

      intelBusId = mkOption {
        type = types.str;
        default = "";
        description = "Bus ID of the Intel GPU.";
        example = "PCI:0:2:0";
      };

      amdgpuBusId = mkOption {
        type = types.str;
        default = "";
        description = "Bus ID of the AMD GPU.";
        example = "PCI:6:0:0";
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = cfg.open;
      nvidiaSettings = false;
      package = cfg.package;

      prime = mkIf cfg.prime.enable {
        offload = mkIf cfg.prime.offload.enable {
          enable = true;
          enableOffloadCmd = cfg.prime.offload.enableOffloadCmd;
        };
        sync.enable = mkIf cfg.prime.sync.enable true;
        nvidiaBusId = mkIf (cfg.prime.nvidiaBusId != "") cfg.prime.nvidiaBusId;
        intelBusId = mkIf (cfg.prime.intelBusId != "") cfg.prime.intelBusId;
        amdgpuBusId = mkIf (cfg.prime.amdgpuBusId != "") cfg.prime.amdgpuBusId;
      };
    };

    environment.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}

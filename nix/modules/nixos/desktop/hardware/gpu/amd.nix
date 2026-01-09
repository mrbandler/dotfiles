{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.gpu.amd;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.gpu.amd = {
    enable = mkEnableOption "AMD GPU support";

    overdrive = {
      enable = mkEnableOption "AMD OverDrive (overclocking)";

      fanControl = mkOption {
        type = types.bool;
        default = false;
        description = "Enable manual fan control.";
      };
    };

    openCL = mkOption {
      type = types.bool;
      default = true;
      description = "Enable OpenCL support via ROCm.";
    };

    vulkan = {
      radv = mkOption {
        type = types.bool;
        default = true;
        description = "Enable RADV Vulkan driver (Mesa).";
      };

      amdvlk = mkOption {
        type = types.bool;
        default = false;
        description = "Enable AMDVLK Vulkan driver (AMD official).";
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.graphics.extraPackages = with pkgs; [
      (mkIf cfg.vulkan.radv mesa)
      (mkIf cfg.vulkan.amdvlk amdvlk)
      (mkIf cfg.openCL rocmPackages.clr.icd)
    ];

    boot.kernelParams = mkIf cfg.overdrive.enable [
      "amdgpu.ppfeaturemask=0xffffffff"
    ];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
    };
  };
}

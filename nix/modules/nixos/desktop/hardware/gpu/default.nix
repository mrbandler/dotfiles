{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.gpu;
  desktopCfg = config.${namespace}.desktop;
in
{
  imports = [
    ./amd.nix
    ./intel.nix
    ./nvidia.nix
  ];

  options.${namespace}.desktop.hardware.gpu = {
    earlyKMS = mkOption {
      type = types.bool;
      default = true;
      description = "Enable early Kernel Mode Setting to avoid boot flickering.";
    };
  };

  config = mkIf desktopCfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    boot.initrd.kernelModules = mkIf cfg.earlyKMS (
      [ ]
      ++ optionals cfg.amd.enable [ "amdgpu" ]
      ++ optionals cfg.intel.enable [ "i915" ]
      ++ optionals cfg.nvidia.enable [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ]
    );
  };
}

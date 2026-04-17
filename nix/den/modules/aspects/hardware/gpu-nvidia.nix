{ den, ... }: {
  den.aspects.hardware-gpu-nvidia = {
    nixos = { pkgs, lib, config, ... }: {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = lib.mkDefault false;
        nvidiaSettings = false;
        package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
      };

      environment.sessionVariables = {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    };
  };
}

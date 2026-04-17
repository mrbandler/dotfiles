{ den, ... }: {
  den.aspects.hardware-gpu-intel = {
    nixos = { pkgs, lib, ... }: {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
        ];
      };

      boot.initrd.kernelModules = [ "i915" ];

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };
    };
  };
}

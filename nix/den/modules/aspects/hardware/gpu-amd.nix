{ den, ... }: {
  den.aspects.hardware-gpu-amd = {
    nixos = { pkgs, lib, ... }: {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          mesa
          rocmPackages.clr.icd
        ];
      };

      services.xserver.videoDrivers = [ "amdgpu" ];

      boot.initrd.kernelModules = [ "amdgpu" ];

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "radeonsi";
        VDPAU_DRIVER = "radeonsi";
      };
    };
  };
}

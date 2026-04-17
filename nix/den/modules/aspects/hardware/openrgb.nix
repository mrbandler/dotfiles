{ den, ... }: {
  den.aspects.hardware-openrgb = {
    nixos = { lib, ... }: {
      services.hardware.openrgb = {
        enable = true;
        motherboard = lib.mkDefault "amd";
      };
    };
  };
}

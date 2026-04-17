{ den, ... }: {
  den.aspects.hardware-displays = {
    nixos = { ... }: {
      hardware.i2c.enable = true;
    };
  };
}

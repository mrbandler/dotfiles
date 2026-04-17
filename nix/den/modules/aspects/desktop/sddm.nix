{ den, ... }: {
  den.aspects.desktop-sddm = {
    nixos = { lib, ... }: {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = lib.mkDefault true;
      };
    };
  };
}

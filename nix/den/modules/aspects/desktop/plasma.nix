{ den, ... }: {
  den.aspects.desktop-plasma = {
    nixos = { ... }: {
      services.desktopManager.plasma6.enable = true;
    };
  };
}

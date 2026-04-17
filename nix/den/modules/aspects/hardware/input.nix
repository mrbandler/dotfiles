{ den, ... }: {
  den.aspects.hardware-input = {
    nixos = { lib, ... }: {
      # Touchpad
      services.libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = lib.mkDefault false;
          tapping = lib.mkDefault true;
          scrollMethod = "twofinger";
          disableWhileTyping = lib.mkDefault true;
        };
      };

      # Wacom
      services.xserver.wacom.enable = lib.mkDefault false;

      # Game controllers
      hardware.xone.enable = lib.mkDefault true;
      hardware.xpadneo.enable = lib.mkDefault true;

      # Logitech
      hardware.logitech.wireless = {
        enable = lib.mkDefault true;
        enableGraphical = true;
      };
    };
  };
}

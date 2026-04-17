{ den, ... }: {
  den.aspects.hardware-audio = {
    nixos = { pkgs, lib, ... }: {
      security.rtkit.enable = true;

      environment.systemPackages = [ pkgs.pulseaudio ];

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = lib.mkDefault false;
      };
    };
  };
}

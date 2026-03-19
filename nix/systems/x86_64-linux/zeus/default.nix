{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.11";

  # UHK (Ultimate Hacking Keyboard) support
  hardware.keyboard.uhk.enable = true;

  internal = {
    core = {
      enable = true;
      networking.hostName = "zeus";
      nix.settings.additionalSubstituters = [ "https://niri.cachix.org" ];
    };

    security._1password.enable = true;

    desktop = {
      enable = true;

      managers = {
        sddm.enable = false;
        dms = {
          enable = true;
          configHome = "/home/mrbandler";
          compositor = "niri";
        };
      };

      environments = {
        plasma.enable = false;
        niri.enable = true;
      };

      hardware = {
        gpu.amd.enable = true;
        audio = {
          backend = "pipewire";
          pipewire = {
            jack = true;
            lowLatency.enable = true;
          };
        };
        input.wacom.enable = true;
      };
      media.hardwareAcceleration.amd = true;

      services = {
        virtualization = {
          enable = true;
          docker.enable = true;
          libvirt = {
            enable = true;
            gui = true;
          };
        };

        gaming = {
          enable = true;
        };
      };
    };
  };
}

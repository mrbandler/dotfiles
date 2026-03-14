{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.11";

  # UHK (Ultimate Hacking Keyboard) support
  hardware.keyboard.uhk.enable = true;
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  internal = {
    core = {
      enable = true;
      networking.hostName = "zeus";
      nix.settings.additionalSubstituters = [ "https://niri.cachix.org" ];
    };

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
        plasma.enable = true;
        niri.enable = true;
      };

      hardware = {
        gpu.amd.enable = true;
        audio.backend = "pipewire";
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

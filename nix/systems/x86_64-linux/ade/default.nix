{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.11";

  internal = {
    core = {
      enable = true;
      networking.hostName = "ade";
    };

    desktop = {
      enable = true;

      managers.sddm.enable = true;
      environments = {
        plasma.enable = true;
        niri.enable = true;
      };

      hardware = {
        gpu.nvidia.enable = true;
        audio.backend = "pipewire";
        input.wacom.enable = true;
      };
      media.hardwareAcceleration.nvidia = true;

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

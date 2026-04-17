{ den, ... }: {
  den.aspects.virtualization = {
    nixos = { pkgs, lib, config, ... }: {
      virtualisation.docker = {
        enable = lib.mkDefault true;
        rootless = {
          enable = lib.mkDefault true;
          setSocketVariable = lib.mkDefault true;
        };
      };

      virtualisation.libvirtd = {
        enable = lib.mkDefault true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
        };
      };

      programs.virt-manager.enable = lib.mkDefault true;

      virtualisation.podman = {
        enable = lib.mkDefault false;
        dockerCompat = lib.mkDefault true;
        defaultNetwork.settings.dns_enabled = true;
      };

      virtualisation.virtualbox.host = {
        enable = lib.mkDefault false;
        enableExtensionPack = lib.mkDefault false;
      };

      virtualisation.waydroid.enable = lib.mkDefault false;

      users.groups.docker = {};
      users.groups.libvirtd = {};
      users.users.mrbandler.extraGroups = [ "docker" "libvirtd" ];
    };
  };
}

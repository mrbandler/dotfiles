{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.virtualization;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.virtualization = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable virtualization support.";
    };

    docker = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Docker.";
      };

      rootless = mkOption {
        type = types.bool;
        default = true;
        description = "Enable rootless Docker.";
      };

      nvidia = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA GPU support in Docker.";
      };
    };

    podman = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Podman.";
      };

      dockerCompat = mkOption {
        type = types.bool;
        default = true;
        description = "Create docker alias for podman.";
      };

      nvidia = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA GPU support in Podman.";
      };
    };

    libvirt = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable libvirt/QEMU/KVM.";
      };

      gui = mkOption {
        type = types.bool;
        default = true;
        description = "Enable virt-manager GUI.";
      };

      ovmf = mkOption {
        type = types.bool;
        default = true;
        description = "Enable UEFI support for VMs.";
      };
    };

    virtualbox = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable VirtualBox.";
      };

      extensionPack = mkOption {
        type = types.bool;
        default = false;
        description = "Enable VirtualBox Extension Pack (requires accepting Oracle license).";
      };
    };

    waydroid = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Waydroid (Android container).";
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # Docker
    virtualisation.docker = mkIf cfg.docker.enable {
      enable = true;
      rootless = mkIf cfg.docker.rootless {
        enable = true;
        setSocketVariable = true;
      };
      enableNvidia = cfg.docker.nvidia;
    };

    # Podman
    virtualisation.podman = mkIf cfg.podman.enable {
      enable = true;
      dockerCompat = cfg.podman.dockerCompat;
      defaultNetwork.settings.dns_enabled = true;
      enableNvidia = cfg.podman.nvidia;
    };

    # libvirt/QEMU/KVM
    virtualisation.libvirtd = mkIf cfg.libvirt.enable {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = cfg.libvirt.ovmf;
        ovmf.packages = mkIf cfg.libvirt.ovmf [ pkgs.OVMFFull.fd ];
        swtpm.enable = true;
      };
    };

    # virt-manager GUI
    programs.virt-manager.enable = mkIf (cfg.libvirt.enable && cfg.libvirt.gui) true;

    # VirtualBox
    virtualisation.virtualbox.host = mkIf cfg.virtualbox.enable {
      enable = true;
      enableExtensionPack = cfg.virtualbox.extensionPack;
    };

    # Waydroid
    virtualisation.waydroid.enable = mkIf cfg.waydroid.enable true;

    # Add users to virtualization groups
    users.groups.docker = mkIf cfg.docker.enable { };
    users.groups.libvirtd = mkIf cfg.libvirt.enable { };
    users.groups.vboxusers = mkIf cfg.virtualbox.enable { };
  };
}

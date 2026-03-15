{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.packages = {
    additionalPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to install system-wide beyond the base set.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        # Essential utilities
        file
        rsync
        tree
        curl
        wget
        unzip
        p7zip

        # System text editor (minimal fallback)
        nano

        # System shell
        bash

        # Version control (system-level)
        git

        # System information and monitoring
        lshw
        pciutils
        usbutils
        killall
        htop

        # Command-not-found functionality
        nix-index

        # Nix language servers
        nixd
        nil

        # Desktop notifications
        libnotify

        # Disk utilities
        parted
        gptfdisk
        dosfstools
        ntfs3g
        exfatprogs
        btrfs-progs
        xfsprogs
        e2fsprogs
        smartmontools
        hdparm
        nvme-cli
      ]
      ++ cfg.packages.additionalPackages;
  };
}

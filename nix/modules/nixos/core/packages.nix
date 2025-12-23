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

        # Text editors (system-level fallbacks)
        nano
        neovim
        helix

        # Shells
        bash
        nushell

        # Terminal utilities
        zellij
        bat
        eza
        ripgrep
        fzf
        fd
        sd
        dust
        bottom
        procs
        btop

        # Network tools
        httpie
        nmap
        dig
        traceroute

        # Version control
        git
        jj

        # System information
        fastfetch
        lshw
        pciutils
        usbutils
        killall

        # Data tools
        jq
        yq-go

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

        # Performance tools
        hyperfine

        # Documentation
        tldr

        # Build essentials
        gcc
        gnumake
        cmake
        pkg-config
        binutils

        # Development environment
        direnv

        # Nix tooling
        nil
        nixd
        nixpkgs-fmt
      ]
      ++ cfg.packages.additionalPackages;
  };
}

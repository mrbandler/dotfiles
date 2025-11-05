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
  options.${namespace}.core.env = {
    editor = lib.mkOption {
      type = lib.types.str;
      default = "hx";
      description = "Default text editor (EDITOR environment variable).";
    };
    pager = lib.mkOption {
      type = lib.types.str;
      default = "less";
      description = "Default pager (PAGER environment variable).";
    };
    additionalPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to install system-wide.";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages =
        with pkgs;
        [
          file
          nano
          neovim
          helix
          nushell
          bash
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
          rsync
          tree
          curl
          wget
          httpie
          nmap
          dig
          traceroute
          unzip
          p7zip
          git
          fastfetch
          lshw
          pciutils
          usbutils
          killall
          jq
          yq-go
          hyperfine
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
          tldr
          gcc
          gnumake
          pkg-config
          binutils
          direnv
        ]
        ++ cfg.env.additionalPackages;
      variables = {
        EDITOR = cfg.env.editor;
        PAGER = cfg.env.pager;
      };
      shellAliases = {
        cat = "bat";
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        grep = "rg";
        find = "fd";
        du = "dust";
        ps = "procs";
        top = "btm";
        htop = "btop";
      };
    };
  };
}

{ den, inputs, ... }: {
  den.aspects.core = {
    nixos = { pkgs, lib, config, ... }:
      let
        userName = lib.mkDefault "mrbandler";
      in
      {
        imports = [
          inputs.nur.modules.nixos.default
        ];

        nixpkgs.config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "ventoy-1.1.10"
          ];
        };

        nixpkgs.overlays = [
          inputs.nur.overlays.default
        ];

        # --- Nix Settings ---
        nix = {
          settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = lib.mkDefault true;
            max-jobs = lib.mkDefault "auto";
            cores = lib.mkDefault 0;
            trusted-users = [ "root" "@wheel" ];
            sandbox = lib.mkDefault true;
            keep-outputs = lib.mkDefault false;
            keep-derivations = lib.mkDefault false;
            warn-dirty = lib.mkDefault true;
            substituters = lib.mkDefault [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
            ];
            min-free = 104857600;
            max-free = 1073741824;
          };

          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };
        };

        # --- Boot ---
        boot = {
          loader = {
            efi.canTouchEfiVariables = lib.mkDefault true;
            systemd-boot = {
              enable = true;
              configurationLimit = 5;
              editor = lib.mkDefault false;
            };
            timeout = 3;
          };

          consoleLogLevel = 4;

          tmp = {
            useTmpfs = true;
            cleanOnBoot = true;
          };

          # Kernel
          kernelPackages = lib.mkDefault pkgs.linuxPackages;

          # Security hardening boot params
          kernelParams = [
            "init_on_alloc=1"
            "init_on_free=1"
            "page_alloc.shuffle=1"
            "slab_nomerge"
          ];

          # Security hardening sysctls
          kernel.sysctl = {
            # Basic
            "kernel.kptr_restrict" = 2;
            "kernel.unprivileged_bpf_disabled" = 1;
            "net.core.bpf_jit_harden" = 2;
            "fs.protected_fifos" = 2;
            "fs.protected_regular" = 2;
            "fs.suid_dumpable" = 0;

            # Moderate network hardening
            "net.ipv4.conf.all.accept_redirects" = false;
            "net.ipv4.conf.default.accept_redirects" = false;
            "net.ipv4.conf.all.secure_redirects" = false;
            "net.ipv4.conf.default.secure_redirects" = false;
            "net.ipv4.conf.all.send_redirects" = false;
            "net.ipv4.conf.default.send_redirects" = false;
            "net.ipv4.conf.all.accept_source_route" = false;
            "net.ipv4.conf.default.accept_source_route" = false;
            "net.ipv4.conf.all.rp_filter" = 1;
            "net.ipv4.conf.default.rp_filter" = 1;
            "net.ipv4.icmp_echo_ignore_broadcasts" = true;
            "net.ipv4.conf.all.log_martians" = true;
            "net.ipv4.conf.default.log_martians" = true;
            "net.ipv6.conf.all.accept_redirects" = false;
            "net.ipv6.conf.default.accept_redirects" = false;
            "net.ipv6.conf.all.accept_source_route" = false;
            "net.ipv6.conf.default.accept_source_route" = false;
            "net.ipv6.conf.all.accept_ra" = 0;
            "net.ipv6.conf.default.accept_ra" = 0;
          };
        };

        systemd.services.nix-daemon.environment = {
          TMPDIR = "/var/tmp";
        };

        # --- Locale ---
        time.timeZone = lib.mkDefault "Europe/Berlin";

        i18n = {
          defaultLocale = lib.mkDefault "en_US.UTF-8";
          extraLocaleSettings = {
            LC_ADDRESS = "de_DE.UTF-8";
            LC_IDENTIFICATION = "de_DE.UTF-8";
            LC_MEASUREMENT = "de_DE.UTF-8";
            LC_MONETARY = "de_DE.UTF-8";
            LC_NAME = "de_DE.UTF-8";
            LC_NUMERIC = "de_DE.UTF-8";
            LC_PAPER = "de_DE.UTF-8";
            LC_TELEPHONE = "de_DE.UTF-8";
            LC_TIME = "de_DE.UTF-8";
          };
        };

        # --- Networking ---
        services.tailscale = {
          enable = lib.mkDefault true;
          port = 0;
        };

        networking = {
          hostName = lib.mkDefault "nixos";
          nameservers = [ "1.0.0.1" "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
          useDHCP = lib.mkDefault false;
          dhcpcd.enable = lib.mkDefault false;

          firewall = {
            enable = true;
          };

          networkmanager = {
            enable = lib.mkDefault true;
            dns = lib.mkDefault "none";
            insertNameservers = [ "1.0.0.1" "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
            wifi.powersave = false;

            settings.connection = {
              "ipv6.addr-gen-mode" = lib.mkDefault "stable-privacy";
              "ipv6.ip6-privacy" = lib.mkDefault "2";
            };
          };
        };

        # --- User ---
        users = {
          defaultUserShell = lib.mkDefault pkgs.bash;
          users.mrbandler = {
            isNormalUser = true;
            description = lib.mkDefault "mrbandler";
            extraGroups = [ "wheel" "networkmanager" "input" ];
          };
        };

        # --- Environment ---
        environment.variables = {
          EDITOR = lib.mkDefault "nano";
          PAGER = lib.mkDefault "less";
        };

        # --- Packages ---
        environment.systemPackages = with pkgs; [
          util-linux file rsync tree curl wget unzip p7zip nmap
          nano bash git
          lshw pciutils usbutils killall htop
          nix-index nixd nil
          libnotify
          parted gptfdisk dosfstools ntfs3g exfatprogs
          btrfs-progs xfsprogs e2fsprogs smartmontools hdparm nvme-cli
        ];

        # --- Documentation ---
        documentation = {
          enable = true;
          nixos.enable = true;
          man.enable = true;
          dev.enable = false;
          info.enable = true;
          doc.enable = true;
        };

        # --- Hardware ---
        hardware = {
          enableAllFirmware = lib.mkDefault true;
          cpu.amd.updateMicrocode = lib.mkDefault true;
          cpu.intel.updateMicrocode = lib.mkDefault true;
        };

        # --- Logging ---
        services.journald.extraConfig = ''
          Storage=persistent
          MaxRetentionSec=1month
          MaxFileSizeMiB=128
          SystemMaxUse=512M
          RateLimitBurst=10000
          RateLimitInterval=30s
          ForwardToSyslog=no
        '';

        # --- Swap (zram) ---
        zramSwap = {
          enable = true;
          memoryPercent = 50;
          priority = 5;
          algorithm = "zstd";
        };

        # --- SSH ---
        services.openssh = {
          enable = lib.mkDefault false;
          ports = [ 22 ];
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
            X11Forwarding = lib.mkDefault false;
            AllowAgentForwarding = lib.mkDefault false;
            AllowTcpForwarding = lib.mkDefault false;
            MaxAuthTries = lib.mkDefault 3;
            MaxSessions = lib.mkDefault 2;
            ClientAliveInterval = lib.mkDefault 300;
            ClientAliveCountMax = lib.mkDefault 0;
            PermitEmptyPasswords = false;
            PermitUserEnvironment = false;
          };
        };

        # --- Security ---
        security.sudo = {
          enable = lib.mkDefault true;
          wheelNeedsPassword = true;
          extraConfig = ''
            Defaults timestamp_timeout=15
          '';
        };

        security.pam.services.su.requireWheel = true;
        security.apparmor.enable = lib.mkDefault true;

        # --- Firmware updates ---
        services.fwupd.enable = true;
        services.thermald.enable = true;
      };
  };
}

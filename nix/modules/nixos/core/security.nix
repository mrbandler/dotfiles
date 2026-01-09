{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.security = {
    sudo = {
      wheelNeedsPassword = mkOption {
        type = types.bool;
        default = true;
        description = "Whether users in the wheel group need a password for sudo.";
      };

      timeout = mkOption {
        type = types.int;
        default = 15;
        description = "Sudo session timeout in minutes.";
      };
    };

    pam = {
      requireWheel = mkOption {
        type = types.bool;
        default = true;
        description = "Require wheel group membership to use su.";
      };
    };

    apparmor = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable AppArmor Mandatory Access Control.";
      };
    };

    kernel = {
      hardening = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable comprehensive kernel hardening (sysctl parameters).";
        };

        level = mkOption {
          type = types.enum [
            "basic"
            "moderate"
            "strict"
          ];
          default = "moderate";
          description = ''
            Kernel hardening level:
            - basic: Essential security with minimal performance impact
            - moderate: Balanced security suitable for most desktops
            - strict: Maximum security (may break some applications)
          '';
        };
      };

      bootParams = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable security-focused kernel boot parameters.";
        };

        level = mkOption {
          type = types.enum [
            "basic"
            "moderate"
          ];
          default = "basic";
          description = ''
            Kernel boot parameter hardening level:
            - basic: Memory zeroing and page randomization
            - moderate: Adds slab hardening (may impact performance slightly)
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Sudo configuration
    security.sudo = {
      enable = mkDefault true;
      wheelNeedsPassword = cfg.security.sudo.wheelNeedsPassword;
      extraConfig = ''
        Defaults timestamp_timeout=${toString cfg.security.sudo.timeout}
      '';
    };

    # PAM configuration
    security.pam.services.su.requireWheel = cfg.security.pam.requireWheel;

    # AppArmor
    security.apparmor.enable = cfg.security.apparmor.enable;

    # Kernel hardening via sysctl
    boot.kernel.sysctl = mkMerge [
      # Basic hardening - always applied when kernel.hardening.enable = true
      (mkIf cfg.security.kernel.hardening.enable {
        # Kernel pointer protection - prevents kernel address leaks
        "kernel.kptr_restrict" = 2;

        # Disable unprivileged BPF
        "kernel.unprivileged_bpf_disabled" = 1;

        # Harden BPF JIT compiler
        "net.core.bpf_jit_harden" = 2;

        # Filesystem protections - prevent FIFO and regular file attacks
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;

        # Disable core dumps for setuid programs
        "fs.suid_dumpable" = 0;
      })

      # Moderate hardening - adds network protections
      (mkIf
        (
          cfg.security.kernel.hardening.enable
          && (
            cfg.security.kernel.hardening.level == "moderate" || cfg.security.kernel.hardening.level == "strict"
          )
        )
        {
          # IPv4 hardening
          "net.ipv4.conf.all.accept_redirects" = false;
          "net.ipv4.conf.default.accept_redirects" = false;
          "net.ipv4.conf.all.secure_redirects" = false;
          "net.ipv4.conf.default.secure_redirects" = false;
          "net.ipv4.conf.all.send_redirects" = false;
          "net.ipv4.conf.default.send_redirects" = false;
          "net.ipv4.conf.all.accept_source_route" = false;
          "net.ipv4.conf.default.accept_source_route" = false;

          # Enable IP spoofing protection (reverse path filtering)
          "net.ipv4.conf.all.rp_filter" = 1;
          "net.ipv4.conf.default.rp_filter" = 1;

          # Ignore ICMP broadcast requests
          "net.ipv4.icmp_echo_ignore_broadcasts" = true;

          # Log suspicious packets (martians)
          "net.ipv4.conf.all.log_martians" = true;
          "net.ipv4.conf.default.log_martians" = true;

          # IPv6 hardening
          "net.ipv6.conf.all.accept_redirects" = false;
          "net.ipv6.conf.default.accept_redirects" = false;
          "net.ipv6.conf.all.accept_source_route" = false;
          "net.ipv6.conf.default.accept_source_route" = false;

          # Disable IPv6 router advertisements
          "net.ipv6.conf.all.accept_ra" = 0;
          "net.ipv6.conf.default.accept_ra" = 0;
        }
      )

      # Strict hardening - maximum security
      (mkIf (cfg.security.kernel.hardening.enable && cfg.security.kernel.hardening.level == "strict") {
        # Disable unprivileged user namespaces (can break some containers/browsers)
        "kernel.unprivileged_userns_clone" = 0;

        # Disable kernel module loading after boot (WARNING: may break some workflows)
        # "kernel.modules_disabled" = 1;  # Commented out - too strict for most desktops

        # Restrict kernel logs to root only
        "kernel.dmesg_restrict" = 1;

        # Restrict access to /proc/<pid> to process owner
        "kernel.yama.ptrace_scope" = 2;
      })
    ];

    # Kernel boot parameters for memory safety
    boot.kernelParams = mkMerge [
      # Basic boot hardening
      (mkIf cfg.security.kernel.bootParams.enable [
        "init_on_alloc=1" # Zero memory on allocation
        "init_on_free=1" # Zero memory on free (prevents info leaks)
        "page_alloc.shuffle=1" # Randomize page allocator freelists
      ])

      # Moderate boot hardening
      (mkIf (cfg.security.kernel.bootParams.enable && cfg.security.kernel.bootParams.level == "moderate")
        [
          "slab_nomerge" # Disable slab merging (prevents heap exploitation)
        ]
      )
    ];
  };
}

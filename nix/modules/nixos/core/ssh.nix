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
  options.${namespace}.core.ssh = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable SSH server.
        Disabled by default for desktop systems for security reasons.
        Even when disabled, the hardened configuration is defined for easy enabling.
      '';
    };

    ports = mkOption {
      type = types.listOf types.port;
      default = [ 22 ];
      description = ''
        SSH listen ports.
        Consider using a non-standard port (e.g., 2222) for additional security.
      '';
    };

    passwordAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Allow password authentication.
        Disabled by default - use SSH keys instead.
        STRONGLY RECOMMENDED: Keep this disabled and use public key authentication.
      '';
    };

    permitRootLogin = mkOption {
      type = types.enum [
        "yes"
        "no"
        "prohibit-password"
        "forced-commands-only"
      ];
      default = "no";
      description = ''
        Whether to allow root login.
        - "no": Root cannot log in via SSH (most secure)
        - "prohibit-password": Root can log in only with SSH keys
        - "yes": Root can log in with password (NOT RECOMMENDED)
        - "forced-commands-only": Root can only run commands specified in authorized_keys
      '';
    };

    allowedUsers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of users allowed to log in via SSH.
        Empty list means all users are allowed.
        Recommended: Explicitly list allowed users for better security.
      '';
    };

    hardening = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable hardened SSH configuration with modern ciphers and security settings.
          Based on Mozilla OpenSSH guidelines and SSH Audit recommendations (2025).
        '';
      };

      fail2ban = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable Fail2Ban to block brute-force SSH attacks.
            Recommended if SSH is exposed to the internet.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = cfg.ssh.enable;
      ports = cfg.ssh.ports;

      settings = mkMerge [
        # Base settings
        {
          PasswordAuthentication = cfg.ssh.passwordAuthentication;
          KbdInteractiveAuthentication = false; # Disable keyboard-interactive auth
          PermitRootLogin = cfg.ssh.permitRootLogin;

          # Disable various forwarding options for security
          X11Forwarding = mkDefault false;
          AllowAgentForwarding = mkDefault false;
          AllowTcpForwarding = mkDefault false;
          AllowStreamLocalForwarding = mkDefault false;
          GatewayPorts = mkDefault "no";
          PermitTunnel = mkDefault "no";

          # Session settings
          MaxAuthTries = mkDefault 3; # Limit auth attempts
          MaxSessions = mkDefault 2; # Limit concurrent sessions
          ClientAliveInterval = mkDefault 300; # 5 minutes
          ClientAliveCountMax = mkDefault 0; # Disconnect idle sessions after 5 min

          # Misc security
          PermitEmptyPasswords = false;
          PermitUserEnvironment = false;
          Compression = mkDefault false; # Avoid CRIME-style attacks
          UseDns = mkDefault false; # Faster connections
          PrintMotd = mkDefault false;
        }

        # Hardened cryptography settings (2025 standards)
        (mkIf cfg.ssh.hardening.enable {
          # Authentication methods - publickey only
          AuthenticationMethods = "publickey";
          PubkeyAuthentication = true;

          # Modern ciphers (prioritize post-quantum resistant and 256-bit)
          Ciphers = [
            "chacha20-poly1305@openssh.com" # Modern, fast, secure
            "aes256-gcm@openssh.com" # Hardware-accelerated AES
            "aes256-ctr"
            "aes192-ctr"
            "aes128-gcm@openssh.com"
            "aes128-ctr"
          ];

          # Modern MACs (Encrypt-then-MAC variants, post-quantum resistant)
          Macs = [
            "hmac-sha2-512-etm@openssh.com" # Post-quantum resistant
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
          ];

          # Modern Key Exchange Algorithms (including post-quantum)
          KexAlgorithms = [
            "sntrup761x25519-sha512@openssh.com" # Post-quantum resistant (added 2025)
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group18-sha512"
            "diffie-hellman-group16-sha512"
            "diffie-hellman-group-exchange-sha256"
          ];

          # Host key algorithms (prefer Ed25519)
          HostKeyAlgorithms = [
            "ssh-ed25519"
            "ssh-ed25519-cert-v01@openssh.com"
            "rsa-sha2-512"
            "rsa-sha2-256"
          ];

          # Use only these host key types
          # Ed25519 is preferred for its efficiency and security
        })
      ];

      # Host keys configuration - prefer Ed25519
      hostKeys = mkIf cfg.ssh.hardening.enable [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
        {
          type = "rsa";
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
        }
      ];

      # Allowed users (set via extraConfig since there's no direct option)
      extraConfig = mkIf (cfg.ssh.allowedUsers != [ ]) ''
        AllowUsers ${concatStringsSep " " cfg.ssh.allowedUsers}
      '';
    };

    # Fail2Ban for SSH brute-force protection
    services.fail2ban = mkIf (cfg.ssh.enable && cfg.ssh.hardening.fail2ban.enable) {
      enable = true;
      maxretry = 3;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
      jails = {
        sshd = ''
          enabled = true
          port = ${concatStringsSep "," (map toString cfg.ssh.ports)}
          filter = sshd
          maxretry = 3
          findtime = 600
          bantime = 3600
        '';
      };
    };

    # Open firewall ports for SSH
    networking.firewall = mkIf cfg.ssh.enable {
      allowedTCPPorts = cfg.ssh.ports;
    };

    # Security notice
    assertions = [
      {
        assertion =
          !cfg.ssh.enable || (!cfg.ssh.passwordAuthentication || cfg.ssh.hardening.fail2ban.enable);
        message = ''
          SSH with password authentication enabled without Fail2Ban is a security risk.
          Either:
          - Set ${namespace}.core.ssh.passwordAuthentication = false (RECOMMENDED)
          - Set ${namespace}.core.ssh.hardening.fail2ban.enable = true
        '';
      }
      {
        assertion = !cfg.ssh.enable || cfg.ssh.permitRootLogin != "yes" || !cfg.ssh.passwordAuthentication;
        message = ''
          Allowing root login with password authentication is a critical security risk.
          Set ${namespace}.core.ssh.permitRootLogin = "no" or "prohibit-password"
        '';
      }
    ];
  };
}

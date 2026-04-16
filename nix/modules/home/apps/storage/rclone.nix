{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.apps.storage.rclone;
  mountOpts = "--vfs-cache-mode writes --vfs-cache-max-age 24h --dir-cache-time 5m --tpslimit 4 --checkers 1";
in
{
  options.internal.apps.storage.rclone = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable rclone cloud drive mounts";
    };

    googleDrive = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Google Drive mount";
      };
      mountPoint = mkOption {
        type = types.str;
        description = "Local mount point for Google Drive";
      };
      clientIdCommand = mkOption {
        type = types.str;
        description = "Command to retrieve Google OAuth2 client ID";
      };
      clientSecretCommand = mkOption {
        type = types.str;
        description = "Command to retrieve Google OAuth2 client secret";
      };
      tokenCommand = mkOption {
        type = types.str;
        description = "Command to retrieve Google OAuth2 token JSON";
      };
    };

    protonDrive = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Proton Drive mount";
      };
      mountPoint = mkOption {
        type = types.str;
        description = "Local mount point for Proton Drive";
      };
      usernameCommand = mkOption {
        type = types.str;
        description = "Command to retrieve Proton username";
      };
      passwordCommand = mkOption {
        type = types.str;
        description = "Command to retrieve Proton password";
      };
      totpSecretCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Command to retrieve Proton TOTP secret for 2FA (null if not used)";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.rclone ];

    # Generate rclone.conf at activation from 1Password secrets
    home.activation.rcloneConfig = let
      configDir = "${config.xdg.configHome}/rclone";
      configFile = "${configDir}/rclone.conf";
      script = pkgs.writeShellScript "rclone-config-gen" (''
        set -euo pipefail
        CONFIG="${configFile}"
        mkdir -p "${configDir}"
        rm -f "$CONFIG"
        touch "$CONFIG"
        chmod 600 "$CONFIG"
      '' + optionalString cfg.googleDrive.enable ''
        CLIENT_ID=$(${cfg.googleDrive.clientIdCommand}) || true
        CLIENT_SECRET=$(${cfg.googleDrive.clientSecretCommand}) || true
        TOKEN=$(${cfg.googleDrive.tokenCommand}) || true
        if [ -n "$CLIENT_ID" ] && [ -n "$CLIENT_SECRET" ] && [ -n "$TOKEN" ]; then
          printf '[gdrive]\ntype = drive\nclient_id = %s\nclient_secret = %s\nscope = drive\ntoken = %s\n\n' \
            "$CLIENT_ID" "$CLIENT_SECRET" "$TOKEN" >> "$CONFIG"
        else
          echo "rclone: Google Drive secrets not yet available, skipping"
        fi
      '' + optionalString cfg.protonDrive.enable (''
        USERNAME=$(${cfg.protonDrive.usernameCommand}) || true
        PASSWORD=$(${cfg.protonDrive.passwordCommand}) || true
      '' + optionalString (cfg.protonDrive.totpSecretCommand != null) ''
        TOTP_SECRET=$(${cfg.protonDrive.totpSecretCommand}) || true
      '' + ''
        if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
          printf '[pdrive]\ntype = protondrive\nusername = %s\npassword = %s\n' \
            "$USERNAME" "$PASSWORD" >> "$CONFIG"
      '' + optionalString (cfg.protonDrive.totpSecretCommand != null) ''
          [ -n "''${TOTP_SECRET:-}" ] && printf 'otp_secret_key = %s\n' "$TOTP_SECRET" >> "$CONFIG"
      '' + ''
          printf '\n' >> "$CONFIG"
        else
          echo "rclone: Proton Drive secrets not yet available, skipping"
        fi
      ''));
    in lib.hm.dag.entryAfter [ "writeBoundary" "injectOpnixSecrets" ] ''
      ${script}
    '';

    # Create mount point directories
    home.activation.rcloneMountDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      concatStringsSep "\n" (
        (optional cfg.googleDrive.enable ''mkdir -p "${cfg.googleDrive.mountPoint}"'')
        ++ (optional cfg.protonDrive.enable ''mkdir -p "${cfg.protonDrive.mountPoint}"'')
      )
    );

    # Add drives to Nautilus sidebar via GTK bookmarks
    home.file.".config/gtk-3.0/bookmarks".text = concatStringsSep "\n" (
      (optional cfg.googleDrive.enable "file://${cfg.googleDrive.mountPoint} Google Drive")
      ++ (optional cfg.protonDrive.enable "file://${cfg.protonDrive.mountPoint} Proton Drive")
    );

    # Systemd user services
    systemd.user.services = mkMerge [
      (mkIf cfg.googleDrive.enable {
        rclone-gdrive = {
          Unit = {
            Description = "rclone mount: Google Drive";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            Type = "notify";
            ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: ${cfg.googleDrive.mountPoint} ${mountOpts}";
            ExecStop = "/run/wrappers/bin/fusermount -u ${cfg.googleDrive.mountPoint}";
            Restart = "on-failure";
            RestartSec = 30;
            Environment = "PATH=/run/wrappers/bin:${pkgs.fuse}/bin:${pkgs.coreutils}/bin";
          };
          Install.WantedBy = [ "default.target" ];
        };
      })
      (mkIf cfg.protonDrive.enable {
        rclone-pdrive = {
          Unit = {
            Description = "rclone mount: Proton Drive";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            Type = "notify";
            ExecStart = "${pkgs.rclone}/bin/rclone mount pdrive: ${cfg.protonDrive.mountPoint} ${mountOpts}";
            ExecStop = "/run/wrappers/bin/fusermount -u ${cfg.protonDrive.mountPoint}";
            Restart = "on-failure";
            RestartSec = 30;
            Environment = "PATH=/run/wrappers/bin:${pkgs.fuse}/bin:${pkgs.coreutils}/bin";
          };
          Install.WantedBy = [ "default.target" ];
        };
      })
    ];
  };
}

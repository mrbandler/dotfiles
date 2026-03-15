{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.maintenance;

  checkUpdatesScript = pkgs.writeShellScript "check-flake-updates" ''
    set -e

    FLAKE_DIR="${cfg.flakePath}"
    cd "$FLAKE_DIR"

    # Store current flake.lock hash
    OLD_HASH=$(sha256sum flake.lock 2>/dev/null | cut -d' ' -f1 || echo "none")

    # Update flake inputs
    ${pkgs.nix}/bin/nix flake update 2>/dev/null

    # Check if flake.lock changed
    NEW_HASH=$(sha256sum flake.lock | cut -d' ' -f1)

    if [ "$OLD_HASH" != "$NEW_HASH" ]; then
      # Updates available - send notification with action
      ACTION=$(${pkgs.libnotify}/bin/notify-send \
        "NixOS Updates Available" \
        "Flake inputs have been updated. Click to rebuild." \
        --icon=software-update-available \
        --action="upgrade=Upgrade Now" \
        --action="dismiss=Later")

      if [ "$ACTION" = "upgrade" ]; then
        ${cfg.terminal} -e bash -c "cd $FLAKE_DIR && just rebuild; echo 'Press Enter to close'; read"
      fi
    fi
  '';
in
{
  options.internal.maintenance = {
    enable = mkEnableOption "system maintenance utilities";

    flakePath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.dotfiles/nix";
      description = "Path to the NixOS flake directory";
    };

    terminal = mkOption {
      type = types.str;
      default = "wezterm";
      description = "Terminal emulator to use for interactive upgrades";
    };

    autoUpdate = {
      enable = mkEnableOption "automatic update checks";

      interval = mkOption {
        type = types.str;
        default = "weekly";
        description = "How often to check for updates (systemd calendar format)";
        example = "daily";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.libnotify ];

    systemd.user.services.check-flake-updates = mkIf cfg.autoUpdate.enable {
      Unit = {
        Description = "Check for NixOS flake updates";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${checkUpdatesScript}";
      };
    };

    systemd.user.timers.check-flake-updates = mkIf cfg.autoUpdate.enable {
      Unit = {
        Description = "Check for NixOS flake updates";
      };
      Timer = {
        OnCalendar = cfg.autoUpdate.interval;
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}

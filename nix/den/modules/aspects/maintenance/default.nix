{ den, ... }: {
  den.aspects.maintenance = {
    homeManager = { pkgs, lib, config, ... }:
      let
        flakePath = "${config.home.homeDirectory}/.dotfiles/nix";
        terminal = "wezterm";

        checkUpdatesScript = pkgs.writeShellScript "check-flake-updates" ''
          set -e

          FLAKE_DIR="${flakePath}"
          cd "$FLAKE_DIR"

          OLD_HASH=$(sha256sum flake.lock 2>/dev/null | cut -d' ' -f1 || echo "none")

          ${pkgs.nix}/bin/nix flake update 2>/dev/null

          NEW_HASH=$(sha256sum flake.lock | cut -d' ' -f1)

          if [ "$OLD_HASH" != "$NEW_HASH" ]; then
            ACTION=$(${pkgs.libnotify}/bin/notify-send \
              "NixOS Updates Available" \
              "Flake inputs have been updated. Click to rebuild." \
              --icon=software-update-available \
              --action="upgrade=Upgrade Now" \
              --action="dismiss=Later")

            if [ "$ACTION" = "upgrade" ]; then
              ${terminal} -e bash -c "cd $FLAKE_DIR && just rebuild; echo 'Press Enter to close'; read"
            fi
          fi
        '';
      in
      {
        home.packages = [ pkgs.libnotify ];

        systemd.user.services.check-flake-updates = {
          Unit.Description = "Check for NixOS flake updates";
          Service = {
            Type = "oneshot";
            ExecStart = "${checkUpdatesScript}";
          };
        };

        systemd.user.timers.check-flake-updates = {
          Unit.Description = "Check for NixOS flake updates";
          Timer = {
            OnCalendar = "monthly";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
  };
}

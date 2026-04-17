{ den, ... }: {
  den.aspects.desktop-keybindings = {
    homeManager = { lib, config, pkgs, ... }:
      with lib;
      let
        st = config.internal.desktop.core.commands.scratchTerminal;
        stFilter = builtins.replaceStrings [ "{appId}" ] [ st.appId ] st.filter;
        stPostSpawn = lib.optionalString (st.postSpawn != null) (
          builtins.replaceStrings [ "{id}" ] [ "$id" ] st.postSpawn
        );
        toggleScratchTerminal = pkgs.writeShellScript "toggle-scratch-terminal" ''
          id=$(${st.check} | ${pkgs.jq}/bin/jq -r '${stFilter}')
          if [ -n "$id" ]; then
            ${builtins.replaceStrings [ "{id}" ] [ "$id" ] st.close}
          else
            ${st.spawn}${lib.optionalString (st.command != null) " -- ${st.command}"} &
            while true; do
              sleep 0.1
              id=$(${st.check} | ${pkgs.jq}/bin/jq -r '${stFilter}')
              if [ -n "$id" ]; then break; fi
            done
            ${stPostSpawn}
          fi
        '';

        matchModule = types.submodule {
          options = {
            appId = mkOption { type = types.nullOr types.str; default = null; };
            title = mkOption { type = types.nullOr types.str; default = null; };
            atStartup = mkOption { type = types.nullOr types.bool; default = null; };
          };
        };
      in
      {
        # === Option declarations (consumed by niri aspect) ===

        options.internal.desktop.core = {
          # --- Keybindings ---
          keybindings = {
            enable = mkEnableOption "desktop keybindings configuration";
            launcherKey = mkOption { type = types.str; default = "XF86Launch1"; };

            monitor = {
              focusMonitorLeft = mkOption { type = types.str; default = "Super+N"; };
              focusMonitorRight = mkOption { type = types.str; default = "Super+Period"; };
              focusMonitorDown = mkOption { type = types.str; default = "Super+M"; };
              focusMonitorUp = mkOption { type = types.str; default = "Super+Comma"; };
              moveToMonitorLeft = mkOption { type = types.str; default = "Super+Alt+N"; };
              moveToMonitorRight = mkOption { type = types.str; default = "Super+Alt+Period"; };
              moveToMonitorDown = mkOption { type = types.str; default = "Super+Alt+M"; };
              moveToMonitorUp = mkOption { type = types.str; default = "Super+Alt+Comma"; };
            };

            navigation = {
              focusColumnLeft = mkOption { type = types.str; default = "Super+H"; };
              focusColumnRight = mkOption { type = types.str; default = "Super+L"; };
              focusWindowUp = mkOption { type = types.str; default = "Super+K"; };
              focusWindowDown = mkOption { type = types.str; default = "Super+J"; };
              moveColumnLeft = mkOption { type = types.str; default = "Super+Alt+H"; };
              moveColumnRight = mkOption { type = types.str; default = "Super+Alt+L"; };
              moveWindowUp = mkOption { type = types.str; default = "Super+Alt+K"; };
              moveWindowDown = mkOption { type = types.str; default = "Super+Alt+J"; };
              focusWorkspaceUp = mkOption { type = types.str; default = "Super+I"; };
              focusWorkspaceDown = mkOption { type = types.str; default = "Super+U"; };
              moveToWorkspaceUp = mkOption { type = types.str; default = "Super+Alt+I"; };
              moveToWorkspaceDown = mkOption { type = types.str; default = "Super+Alt+U"; };
              focusFirstColumn = mkOption { type = types.str; default = "Super+Home"; };
              focusLastColumn = mkOption { type = types.str; default = "Super+End"; };
              moveColumnFirst = mkOption { type = types.str; default = "Super+Alt+Home"; };
              moveColumnLast = mkOption { type = types.str; default = "Super+Alt+End"; };
              consumeFromLeft = mkOption { type = types.str; default = "Super+BracketLeft"; };
              consumeFromRight = mkOption { type = types.str; default = "Super+BracketRight"; };
              expelToLeft = mkOption { type = types.str; default = "Super+Alt+BracketLeft"; };
              expelToRight = mkOption { type = types.str; default = "Super+Alt+BracketRight"; };
              focusWorkspacePrefix = mkOption { type = types.str; default = "Super"; };
              moveToWorkspacePrefix = mkOption { type = types.str; default = "Super+Alt"; };
            };

            layout = {
              resizeWidthDecrease = mkOption { type = types.str; default = "Super+Minus"; };
              resizeWidthIncrease = mkOption { type = types.str; default = "Super+Equal"; };
              resizeHeightDecrease = mkOption { type = types.str; default = "Super+Alt+Minus"; };
              resizeHeightIncrease = mkOption { type = types.str; default = "Super+Alt+Equal"; };
              cyclePresetWidth = mkOption { type = types.str; default = "Super+R"; };
              cyclePresetHeight = mkOption { type = types.str; default = "Super+Alt+R"; };
              maximize = mkOption { type = types.str; default = "Super+F"; };
              fullscreen = mkOption { type = types.str; default = "Super+Alt+F"; };
              expand = mkOption { type = types.str; default = "Super+X"; };
              center = mkOption { type = types.str; default = "Super+C"; };
              toggleFloating = mkOption { type = types.str; default = "Super+V"; };
              switchFloatingFocus = mkOption { type = types.str; default = "Super+Alt+V"; };
              toggleTabbed = mkOption { type = types.str; default = "Super+T"; };
            };

            applications = {
              terminal = mkOption { type = types.str; default = "Super+Return"; };
              scratchTerminal = mkOption { type = types.str; default = "Super+Alt+Return"; };
              fileManager = mkOption { type = types.str; default = "Super+E"; };
              browser = mkOption { type = types.str; default = "Super+B"; };
              privateBrowser = mkOption { type = types.str; default = "Super+Alt+B"; };
              passwordManager = mkOption { type = types.str; default = "Super+S"; };
            };

            window = {
              close = mkOption { type = types.listOf types.str; default = [ "Super+Q" "Super+Y" ]; };
              overview = mkOption { type = types.str; default = "Super+O"; };
              inhibitShortcuts = mkOption { type = types.str; default = "Super+Escape"; };
            };

            media = {
              volumeUp = mkOption { type = types.str; default = "XF86AudioRaiseVolume"; };
              volumeDown = mkOption { type = types.str; default = "XF86AudioLowerVolume"; };
              mute = mkOption { type = types.str; default = "XF86AudioMute"; };
              micMute = mkOption { type = types.str; default = "XF86AudioMicMute"; };
              play = mkOption { type = types.str; default = "XF86AudioPlay"; };
              stop = mkOption { type = types.str; default = "XF86AudioStop"; };
              prev = mkOption { type = types.str; default = "XF86AudioPrev"; };
              next = mkOption { type = types.str; default = "XF86AudioNext"; };
            };

            desktopShell = {
              spotlight = mkOption { type = types.str; default = "Super+D"; };
              notifications = mkOption { type = types.str; default = "Super+G"; };
              lock = mkOption { type = types.str; default = "Super+A"; };
              powerMenu = mkOption { type = types.str; default = "Super+P"; };
              processlist = mkOption { type = types.str; default = "Ctrl+Shift+Escape"; };
            };

            extraNiri = mkOption {
              type = types.listOf (types.submodule {
                options = {
                  key = mkOption { type = types.str; };
                  action = mkOption { type = types.str; };
                  args = mkOption { type = types.listOf types.str; default = []; };
                };
              });
              default = [];
            };

            extraXremap = mkOption { type = types.attrs; default = {}; };
          };

          # --- Commands ---
          commands = {
            applications = {
              terminal = mkOption { type = types.listOf types.str; default = [ "sh" "-c" "$TERMINAL" ]; };
              fileManager = mkOption { type = types.listOf types.str; default = [ "sh" "-c" "$FILEMANAGER" ]; };
              browser = mkOption { type = types.listOf types.str; default = [ "sh" "-c" "$BROWSER" ]; };
              privateBrowser = mkOption { type = types.listOf types.str; default = [ "sh" "-c" "$BROWSER --private-window" ]; };
              launcher = mkOption { type = types.listOf types.str; default = [ "sh" "-c" "$LAUNCHER" ]; };
              passwordManager = mkOption { type = types.listOf types.str; default = [ "sh" "-c" "$PASS" ]; };
            };

            scratchTerminal = {
              spawn = mkOption { type = types.str; default = "\${TERMINAL} start --class scratch-terminal"; };
              command = mkOption { type = types.nullOr types.str; default = null; };
              appId = mkOption { type = types.str; default = "scratch-terminal"; };
              check = mkOption { type = types.str; default = "niri msg --json windows"; };
              filter = mkOption { type = types.str; default = ''.[] | select(.app_id == "{appId}") | .id''; };
              close = mkOption { type = types.str; default = "niri msg action close-window --id {id}"; };
              postSpawn = mkOption { type = types.nullOr types.str; default = null; };
              script = mkOption { type = types.path; readOnly = true; };
            };

            desktopShell = {
              spotlight = mkOption { type = types.listOf types.str; default = [ "dms" "ipc" "call" "spotlight" "toggle" ]; };
              notifications = mkOption { type = types.listOf types.str; default = [ "dms" "ipc" "call" "notifications" "toggle" ]; };
              lock = mkOption { type = types.listOf types.str; default = [ "dms" "ipc" "call" "lock" "lock" ]; };
              powerMenu = mkOption { type = types.listOf types.str; default = [ "dms" "ipc" "call" "powermenu" "toggle" ]; };
              processlist = mkOption { type = types.listOf types.str; default = [ "dms" "ipc" "call" "processlist" "toggle" ]; };
            };

            media = {
              volumeUp = mkOption { type = types.listOf types.str; default = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" "-l" "1.0" ]; };
              volumeDown = mkOption { type = types.listOf types.str; default = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ]; };
              mute = mkOption { type = types.listOf types.str; default = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ]; };
              micMute = mkOption { type = types.listOf types.str; default = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ]; };
              play = mkOption { type = types.listOf types.str; default = [ "playerctl" "play-pause" ]; };
              stop = mkOption { type = types.listOf types.str; default = [ "playerctl" "stop" ]; };
              prev = mkOption { type = types.listOf types.str; default = [ "playerctl" "previous" ]; };
              next = mkOption { type = types.listOf types.str; default = [ "playerctl" "next" ]; };
            };
          };

          # --- Init ---
          init.spawn = mkOption {
            type = types.listOf (types.listOf types.str);
            default = [];
          };

          # --- Workspaces ---
          workspaces = mkOption {
            type = types.listOf (types.submodule {
              options = {
                name = mkOption { type = types.str; };
                displayName = mkOption { type = types.nullOr types.str; default = null; };
                monitor = mkOption { type = types.nullOr types.str; default = null; };
              };
            });
            default = [];
          };

          # --- Window Rules ---
          windowRules = mkOption {
            type = types.listOf (types.submodule {
              options = {
                matches = mkOption { type = types.listOf matchModule; default = []; };
                excludes = mkOption { type = types.listOf matchModule; default = []; };
                properties = mkOption { type = types.attrs; default = {}; };
              };
            });
            default = [];
          };
        };

        # === Config ===
        config = {
          internal.desktop.core.commands.scratchTerminal.script = toggleScratchTerminal;

          # Default scratch terminal window rule
          internal.desktop.core.windowRules = [
            {
              matches = [{ appId = "^${lib.escape [ "." ] st.appId}$"; }];
              properties = {
                open-floating = true;
                open-focused = true;
                default-column-width = { proportion = 0.75; };
                default-window-height = { proportion = 0.75; };
              };
            }
          ];
        };
      };
  };
}

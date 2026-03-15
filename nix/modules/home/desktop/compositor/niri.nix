{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.desktop.core.keybindings;
  cmds = config.internal.desktop.core.commands;
  initCfg = config.internal.desktop.core.init;
  wsCfg = config.internal.desktop.core.workspaces;
  wrCfg = config.internal.desktop.core.windowRules;

  # Translate a core match/exclude entry to niri's attribute names
  toNiriMatch = m:
    lib.filterAttrs (_: v: v != null) (
      (lib.optionalAttrs (m.appId != null) { app-id = m.appId; })
      // (lib.optionalAttrs (m.title != null) { title = m.title; })
      // (lib.optionalAttrs (m.atStartup != null) { at-startup = m.atStartup; })
    );

  # Translate a core window rule to a niri window rule
  toNiriWindowRule = rule:
    (lib.optionalAttrs (rule.matches != []) { matches = map toNiriMatch rule.matches; })
    // (lib.optionalAttrs (rule.excludes != []) { excludes = map toNiriMatch rule.excludes; })
    // rule.properties;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "desktop" "compositor" "niri" ] [ "programs" "niri" ])
  ];

  config = {
    programs.niri = {
      package = pkgs.niri;
      settings = {
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;

        spawn-at-startup = map (cmd: { command = cmd; }) initCfg.spawn;

        workspaces = builtins.listToAttrs (map (ws: {
          name = ws.name;
          value = { name = if ws.displayName != null then ws.displayName else ws.name; }
            // lib.optionalAttrs (ws.monitor != null) { open-on-output = ws.monitor; };
        }) wsCfg);

        input = {
          keyboard = {
            xkb = {
              layout = "us,de";
              options = "grp:win_space_toggle";
            };
            repeat-delay = 600;
            repeat-rate = 25;
            track-layout = "global";
          };

          touchpad = {
            tap = true;
            dwt = true;
            natural-scroll = true;
            accel-speed = 0.0;
            accel-profile = "adaptive";
          };

          mouse = {
            accel-speed = 0.0;
            accel-profile = "adaptive";
            natural-scroll = false;
          };
        };

        overview = {
          backdrop-color = "#${config.lib.stylix.colors.base00}";
        };

        layout = {
          center-focused-column = "never";
          gaps = 10;

          default-column-width = {
            proportion = 0.5;
          };

          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
            { proportion = 1.0; }
          ];

          preset-window-heights = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
            { proportion = 1.0; }
          ];

          background-color = "#${config.lib.stylix.colors.base00}";
          focus-ring = {
            width = 1;
            active.gradient = {
              from = "#${config.lib.stylix.colors.base0C}";
              to = "#${config.lib.stylix.colors.base0D}";
              angle = 90;
              relative-to = "workspace-view";
            };
            inactive.color = "#${config.lib.stylix.colors.base03}";
            urgent.gradient = {
              from = "#${config.lib.stylix.colors.base08}";
              to = "#${config.lib.stylix.colors.base09}";
              angle = 90;
              relative-to = "workspace-view";
            };
          };

          shadow = {
            enable = true;
            softness = 30;
            spread = 5;
            offset = {
              x = 0;
              y = 5;
            };
            color = "#0007";
          };

          struts = {};
        };

        window-rules = [
          {
            clip-to-geometry = true;
            geometry-corner-radius = {
              top-left = 5.0;
              top-right = 5.0;
              bottom-left = 5.0;
              bottom-right = 5.0;
            };
          }
        ] ++ (map toNiriWindowRule wrCfg);

        binds = mkIf cfg.enable (
          let
            nav = cfg.navigation;
            lay = cfg.layout;
            win = cfg.window;
            app = cfg.applications;
            mon = cfg.monitor;
          in
          {
            # === Launcher (via xremap F-key) ===
            "${cfg.launcherKey}".action.spawn = cmds.applications.launcher;

            # === Applications ===
            "${app.terminal}".action.spawn = cmds.applications.terminal;
            "${app.fileManager}".action.spawn = cmds.applications.fileManager;
            "${app.browser}".action.spawn = cmds.applications.browser;

            # === Window actions ===
            "${win.overview}" = {
              repeat = false;
              action.toggle-overview = {};
            };
            "${win.inhibitShortcuts}" = {
              allow-inhibiting = false;
              action.toggle-keyboard-shortcuts-inhibit = {};
            };
          }
          // (builtins.listToAttrs (map (key: {
            name = key;
            value = { repeat = false; action.close-window = {}; };
          }) win.close))

          # === Navigation ===
          // {
            "${nav.focusColumnLeft}".action.focus-column-left = {};
            "${nav.focusColumnRight}".action.focus-column-right = {};
            "${nav.focusWindowUp}".action.focus-window-up = {};
            "${nav.focusWindowDown}".action.focus-window-down = {};
            "${nav.moveColumnLeft}".action.move-column-left = {};
            "${nav.moveColumnRight}".action.move-column-right = {};
            "${nav.moveWindowUp}".action.move-window-up = {};
            "${nav.moveWindowDown}".action.move-window-down = {};
            "${nav.focusWorkspaceUp}".action.focus-workspace-up = {};
            "${nav.focusWorkspaceDown}".action.focus-workspace-down = {};
            "${nav.moveToWorkspaceUp}".action.move-column-to-workspace-up = {};
            "${nav.moveToWorkspaceDown}".action.move-column-to-workspace-down = {};
            "${nav.focusFirstColumn}".action.focus-column-first = {};
            "${nav.focusLastColumn}".action.focus-column-last = {};
            "${nav.moveColumnFirst}".action.move-column-to-first = {};
            "${nav.moveColumnLast}".action.move-column-to-last = {};
            "${nav.consumeFromLeft}".action.consume-or-expel-window-left = {};
            "${nav.consumeFromRight}".action.consume-or-expel-window-right = {};
            "${nav.expelToLeft}".action.consume-or-expel-window-left = {};
            "${nav.expelToRight}".action.consume-or-expel-window-right = {};
          }

          # === Mouse wheel workspace ===
          // {
            "Super+WheelScrollUp" = {
              cooldown-ms = 150;
              action.focus-workspace-up = {};
            };
            "Super+WheelScrollDown" = {
              cooldown-ms = 150;
              action.focus-workspace-down = {};
            };
          }

          # === Monitor navigation ===
          // {
            "${mon.focusMonitorLeft}".action.focus-monitor-left = {};
            "${mon.focusMonitorRight}".action.focus-monitor-right = {};
            "${mon.focusMonitorDown}".action.focus-monitor-down = {};
            "${mon.focusMonitorUp}".action.focus-monitor-up = {};
            "${mon.moveToMonitorLeft}".action.move-column-to-monitor-left = {};
            "${mon.moveToMonitorRight}".action.move-column-to-monitor-right = {};
            "${mon.moveToMonitorDown}".action.move-column-to-monitor-down = {};
            "${mon.moveToMonitorUp}".action.move-column-to-monitor-up = {};
          }

          # === Layout ===
          // {
            "${lay.resizeWidthDecrease}".action.set-column-width = "-10%";
            "${lay.resizeWidthIncrease}".action.set-column-width = "+10%";
            "${lay.resizeHeightDecrease}".action.set-window-height = "-10%";
            "${lay.resizeHeightIncrease}".action.set-window-height = "+10%";
            "${lay.cyclePresetWidth}".action.switch-preset-column-width = {};
            "${lay.cyclePresetHeight}".action.switch-preset-window-height = {};
            "${lay.maximize}".action.maximize-column = {};
            "${lay.fullscreen}".action.fullscreen-window = {};
            "${lay.expand}".action.expand-column-to-available-width = {};
            "${lay.center}".action.center-column = {};
            "${lay.toggleFloating}".action.toggle-window-floating = {};
            "${lay.switchFloatingFocus}".action.switch-focus-between-floating-and-tiling = {};
            "${lay.toggleTabbed}".action.toggle-column-tabbed-display = {};
          }

          # === Screenshots ===
          // {
            "Print".action.screenshot = {};
            "Ctrl+Print".action.screenshot-screen = {};
            "Alt+Print".action.screenshot-window = {};
          }

          # === Media keys ===
          // {
            ${cfg.media.volumeUp} = {
              allow-when-locked = true;
              action.spawn = cmds.media.volumeUp;
            };
            ${cfg.media.volumeDown} = {
              allow-when-locked = true;
              action.spawn = cmds.media.volumeDown;
            };
            ${cfg.media.mute} = {
              allow-when-locked = true;
              action.spawn = cmds.media.mute;
            };
            ${cfg.media.micMute} = {
              allow-when-locked = true;
              action.spawn = cmds.media.micMute;
            };
            ${cfg.media.play} = {
              allow-when-locked = true;
              action.spawn = cmds.media.play;
            };
            ${cfg.media.stop} = {
              allow-when-locked = true;
              action.spawn = cmds.media.stop;
            };
            ${cfg.media.prev} = {
              allow-when-locked = true;
              action.spawn = cmds.media.prev;
            };
            ${cfg.media.next} = {
              allow-when-locked = true;
              action.spawn = cmds.media.next;
            };
          }

          # === Desktop Shell (DMS) ===
          // {
            "${cfg.desktopShell.spotlight}".action.spawn = cmds.desktopShell.spotlight;
            "${cfg.desktopShell.notifications}".action.spawn = cmds.desktopShell.notifications;
            "${cfg.desktopShell.lock}".action.spawn = cmds.desktopShell.lock;
            "${cfg.desktopShell.powerMenu}".action.spawn = cmds.desktopShell.powerMenu;
            "${cfg.desktopShell.processlist}".action.spawn = cmds.desktopShell.processlist;
          }

          # === Extra custom bindings from escape hatch ===
          // (builtins.listToAttrs (map (binding: {
            name = binding.key;
            value.action.${binding.action} =
              if binding.args == [] then {} else binding.args;
          }) cfg.extraNiri))
        );
      };
    };
  };
}

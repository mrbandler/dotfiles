{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "desktop" "niri" ] [ "programs" "niri" ])
  ];

  config = {
    programs.niri = {
      package = pkgs.niri;
      settings = {
        prefer-no-csd = true;

        spawn-at-startup = [
          { command = ["vicinae" "server"]; }
        ];

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
            dwt = true;  # disable-while-typing
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
          backdrop-color = "#${config.lib.stylix.colors.base01}";
        };

        layout = {
          center-focused-column = "never";
          gaps = 20;

          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];

          default-column-width = {
            proportion = 0.5;
          };

          background-color = "#${config.lib.stylix.colors.base00}";
          focus-ring = {
            width = 3;
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
              top-left = 12.0;
              top-right = 12.0;
              bottom-left = 12.0;
              bottom-right = 12.0;
            };
          }
        ];

        binds = {
          "Super+D".action.spawn = [ "vicinae" "toggle" ];
          "Super+T".action.spawn = [ "wezterm" ];

          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" "-l" "1.0" ];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked=true;
            action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
          };

          "XF86AudioPlay" = {
            allow-when-locked = true;
            action.spawn = [ "playerctl" "play-pause" ];
          };
          "XF86AudioStop" = {
            allow-when-locked = true;
            action.spawn = [ "playerctl" "stop" ];
          };
          "XF86AudioPrev" = {
            allow-when-locked = true;
            action.spawn = [ "playerctl previous" ];
          };
          "XF86AudioNext" = {
            allow-when-locked = true;
            action.spawn-sh = "playerctl next";
          };

          "Super+O" = {
            repeat=false;
            action.toggle-overview = {};
          };
          "Super+Q" = {
            repeat=false;
            action.close-window = {};
          };

          "Super+Left".action.focus-column-left = {};
          "Super+Down".action.focus-window-down = {};
          "Super+Up".action.focus-window-up = {};
          "Super+Right".action.focus-column-right = {};
          "Super+H".action.focus-column-left = {};
          "Super+J".action.focus-window-down = {};
          "Super+K".action.focus-window-up = {};
          "Super+L".action.focus-column-right = {};

          "Super+Ctrl+Left".action.move-column-left = {};
          "Super+Ctrl+Down".action.move-window-down = {};
          "Super+Ctrl+Up".action.move-window-up = {};
          "Super+Ctrl+Right".action.move-column-right = {};
          "Super+Ctrl+H".action.move-column-left = {};
          "Super+Ctrl+J".action.move-window-down = {};
          "Super+Ctrl+K".action.move-window-up = {};
          "Super+Ctrl+L".action.move-column-right = {};

          "Super+Home".action.focus-column-first = {};
          "Super+End".action.focus-column-last = {};
          "Super+Ctrl+Home".action.move-column-to-first = {};
          "Super+Ctrl+End".action.move-column-to-last = {};

          "Super+Shift+Left".action.focus-monitor-left = {};
          "Super+Shift+Down".action.focus-monitor-down = {};
          "Super+Shift+Up".action.focus-monitor-up = {};
          "Super+Shift+Right".action.focus-monitor-right = {};
          "Super+Shift+H".action.focus-monitor-left = {};
          "Super+Shift+J".action.focus-monitor-down = {};
          "Super+Shift+K".action.focus-monitor-up = {};
          "Super+Shift+L".action.focus-monitor-right = {};

          "Super+Shift+Ctrl+Left".action.move-column-to-monitor-left = {};
          "Super+Shift+Ctrl+Down".action.move-column-to-monitor-down = {};
          "Super+Shift+Ctrl+Up".action.move-column-to-monitor-up = {};
          "Super+Shift+Ctrl+Right".action.move-column-to-monitor-right = {};
          "Super+Shift+Ctrl+H".action.move-column-to-monitor-left = {};
          "Super+Shift+Ctrl+J".action.move-column-to-monitor-down = {};
          "Super+Shift+Ctrl+K".action.move-column-to-monitor-up = {};
          "Super+Shift+Ctrl+L".action.move-column-to-monitor-right = {};

          "Super+Page_Down".action.focus-workspace-down = {};
          "Super+Page_Up".action.focus-workspace-up = {};
          "Super+U".action.focus-workspace-down = {};
          "Super+I".action.focus-workspace-up = {};
          "Super+Ctrl+Page_Down".action.move-column-to-workspace-down = {};
          "Super+Ctrl+Page_Up".action.move-column-to-workspace-up = {};
          "Super+Ctrl+U".action.move-column-to-workspace-down = {};
          "Super+Ctrl+I".action.move-column-to-workspace-up = {};

          "Super+Shift+Page_Down".action.move-workspace-down = {};
          "Super+Shift+Page_Up".action.move-workspace-up = {};
          "Super+Shift+U".action.move-workspace-down = {};
          "Super+Shift+I".action.move-workspace-up = {};

          "Super+WheelScrollDown" = {
            cooldown-ms = 150;
            action.focus-workspace-down = {};
          };
          "Super+WheelScrollUp" = {
            cooldown-ms = 150;
            action.focus-workspace-up = {};
          };
          "Super+Ctrl+WheelScrollDown" = {
            cooldown-ms = 150;
            action.move-column-to-workspace-down = {};
          };
          "Super+Ctrl+WheelScrollUp" = {
            cooldown-ms=150;
            action.move-column-to-workspace-up = {};
          };

          "Super+Shift+WheelScrollDown" = {
            cooldown-ms = 150;
            action.focus-column-right = {};
          };
          "Super+Shift+WheelScrollUp" = {
            cooldown-ms = 150;
            action.focus-column-left = {};
          };
          "Super+Ctrl+Shift+WheelScrollDown" = {
            cooldown-ms = 150;
            action.move-column-right = {};
          };
          "Super+Ctrl+Shift+WheelScrollUp" = {
            cooldown-ms = 150;
            action.move-column-left = {};
          };

          "Super+1".action.focus-workspace = 1;
          "Super+2".action.focus-workspace = 2;
          "Super+3".action.focus-workspace = 3;
          "Super+4".action.focus-workspace = 4;
          "Super+5".action.focus-workspace = 5;
          "Super+6".action.focus-workspace = 6;
          "Super+7".action.focus-workspace = 7;
          "Super+8".action.focus-workspace = 8;
          "Super+9".action.focus-workspace = 9;
          "Super+Ctrl+1".action.move-column-to-workspace = 1;
          "Super+Ctrl+2".action.move-column-to-workspace = 2;
          "Super+Ctrl+3".action.move-column-to-workspace = 3;
          "Super+Ctrl+4".action.move-column-to-workspace = 4;
          "Super+Ctrl+5".action.move-column-to-workspace = 5;
          "Super+Ctrl+6".action.move-column-to-workspace = 6;
          "Super+Ctrl+7".action.move-column-to-workspace = 7;
          "Super+Ctrl+8".action.move-column-to-workspace = 8;
          "Super+Ctrl+9".action.move-column-to-workspace = 9;

          "Super+BracketLeft".action.consume-or-expel-window-left = {};
          "Super+BracketRight".action.consume-or-expel-window-right = {};
          "Super+Comma".action.consume-window-into-column = {};
          "Super+Period".action.expel-window-from-column = {};

          "Mod+R".action.switch-preset-column-width = {};
          "Mod+Shift+R".action.switch-preset-window-height = {};
          "Mod+Ctrl+R".action.reset-window-height = {};

          "Mod+F".action.maximize-column = {};
          "Mod+Shift+F".action.fullscreen-window = {};
          "Mod+M".action.maximize-window-to-edges = {};
          "Mod+Ctrl+F".action.expand-column-to-available-width = {};
          "Mod+C".action.center-column = {};
          "Mod+Ctrl+C".action.center-visible-columns = {};

          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          "Mod+V".action.toggle-window-floating = {};
          "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = {};

          "Mod+W".action.toggle-column-tabbed-display = {};

          "Print".action.screenshot = {};
          "Ctrl+Print".action.screenshot-screen = {};
          "Alt+Print".action.screenshot-window = {};

          "Mod+Escape" = {
            allow-inhibiting = false;
            action.toggle-keyboard-shortcuts-inhibit = {};
          };
        };
      };
    };
  };
}

{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.desktop.core.keybindings;

  # Mapping from XKB keysyms (used by Niri) to evdev key names (used by xremap)
  # xremap sends evdev keycodes, XKB translates them to keysyms
  xkbToEvdev = {
    "XF86Launch1" = "Prog1";
    "XF86Launch2" = "Prog2";
    "XF86Launch3" = "Prog3";
    "XF86Launch4" = "Prog4";
    "XF86Mail" = "Mail";
    "XF86Calculator" = "Calc";
    "XF86HomePage" = "HomePage";
    "XF86Favorites" = "Favorites";
    "XF86Search" = "Search";
  };

  # Convert a keybinding keysym to evdev key name
  toEvdev = keysym: xkbToEvdev.${keysym} or keysym;
in
{
  config = mkIf cfg.enable {
    services.xremap = {
      enable = true;
      withWlroots = true;

      config = {
        modmap = [
          {
            name = "Super tap to launcher";
            remap = {
              Super_L = {
                held = "Super_L";
                alone = toEvdev cfg.launcherKey;
                alone_timeout_millis = 200;
              };
            };
          }
        ];

        keymap = [
          {
            name = "Monitor focus mode entry";
            remap = {
              Super_L-m = [
                { launch = [ "dms" "ipc" "toast" "warn" "Monitor Focus Mode" ]; }
                { set_mode = "monitor_focus"; }
              ];
            };
          }
          {
            name = "Monitor move mode entry";
            remap = {
              Super_L-Alt_L-m = [
                { launch = [ "dms" "ipc" "toast" "warn" "Monitor Move Mode" ]; }
                { set_mode = "monitor_move"; }
              ];
            };
          }
          {
            name = "Monitor focus mode keys";
            mode = "monitor_focus";
            remap = {
              h = toEvdev cfg.monitorMode.focusLeft;
              l = toEvdev cfg.monitorMode.focusRight;
              j = toEvdev cfg.monitorMode.focusDown;
              k = toEvdev cfg.monitorMode.focusUp;
              Esc = [
                { launch = [ "dms" "ipc" "toast" "dismiss" ]; }
                { set_mode = "default"; }
              ];
            };
          }
          {
            name = "Monitor move mode keys";
            mode = "monitor_move";
            remap = {
              h = toEvdev cfg.monitorMode.moveLeft;
              l = toEvdev cfg.monitorMode.moveRight;
              j = toEvdev cfg.monitorMode.moveDown;
              k = toEvdev cfg.monitorMode.moveUp;
              Esc = [
                { launch = [ "dms" "ipc" "toast" "dismiss" ]; }
                { set_mode = "default"; }
              ];
            };
          }
        ];
      } // cfg.extraXremap;
    };
  };
}

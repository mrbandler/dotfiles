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

        keymap = [];
      } // cfg.extraXremap;
    };
  };
}

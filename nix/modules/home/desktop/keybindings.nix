{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.desktop.keybindings;
in
{
  options.internal.desktop.keybindings = {
    enable = mkEnableOption "desktop keybindings configuration";

    # === Coordination keys (used by both xremap and Niri) ===
    # These use XF86 keysyms because xremap sends evdev keycodes,
    # and XKB translates them to XF86* keysyms (not F13-F24).
    # xremap key → XKB keysym: Prog1→XF86Launch1, Mail→XF86Mail, etc.
    launcherKey = mkOption {
      type = types.str;
      default = "XF86Launch1";
      description = "Key sent by Super tap for launcher (xremap: Prog1)";
    };

    monitorMode = {
      focusLeft = mkOption { type = types.str; default = "XF86Launch2"; };
      focusRight = mkOption { type = types.str; default = "XF86Launch3"; };
      focusDown = mkOption { type = types.str; default = "XF86Launch4"; };
      focusUp = mkOption { type = types.str; default = "XF86Mail"; };
      moveLeft = mkOption { type = types.str; default = "XF86Calculator"; };
      moveRight = mkOption { type = types.str; default = "XF86HomePage"; };
      moveDown = mkOption { type = types.str; default = "XF86Favorites"; };
      moveUp = mkOption { type = types.str; default = "XF86Search"; };
    };

    # === Navigation ===
    navigation = {
      focusColumnLeft = mkOption { type = types.str; default = "Super+H"; };
      focusColumnRight = mkOption { type = types.str; default = "Super+L"; };
      focusWindowUp = mkOption { type = types.str; default = "Super+K"; };
      focusWindowDown = mkOption { type = types.str; default = "Super+J"; };
      moveColumnLeft = mkOption { type = types.str; default = "Super+Alt+H"; };
      moveColumnRight = mkOption { type = types.str; default = "Super+Alt+L"; };
      moveWindowUp = mkOption { type = types.str; default = "Super+Alt+K"; };
      moveWindowDown = mkOption { type = types.str; default = "Super+Alt+J"; };
      focusWorkspaceUp = mkOption { type = types.str; default = "Super+U"; };
      focusWorkspaceDown = mkOption { type = types.str; default = "Super+I"; };
      moveToWorkspaceUp = mkOption { type = types.str; default = "Super+Alt+U"; };
      moveToWorkspaceDown = mkOption { type = types.str; default = "Super+Alt+I"; };
      focusFirstColumn = mkOption { type = types.str; default = "Super+Home"; };
      focusLastColumn = mkOption { type = types.str; default = "Super+End"; };
      moveColumnFirst = mkOption { type = types.str; default = "Super+Alt+Home"; };
      moveColumnLast = mkOption { type = types.str; default = "Super+Alt+End"; };
      consumeFromLeft = mkOption { type = types.str; default = "Super+BracketLeft"; };
      consumeFromRight = mkOption { type = types.str; default = "Super+BracketRight"; };
      expelToLeft = mkOption { type = types.str; default = "Super+Alt+BracketLeft"; };
      expelToRight = mkOption { type = types.str; default = "Super+Alt+BracketRight"; };
    };

    # === Monitor (mode entry keys) ===
    monitor = {
      enterFocusMode = mkOption { type = types.str; default = "Super+M"; };
      enterMoveMode = mkOption { type = types.str; default = "Super+Alt+M"; };
    };

    # === Layout ===
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

    # === Applications ===
    applications = {
      terminal = mkOption { type = types.str; default = "Super+Return"; };
      fileManager = mkOption { type = types.str; default = "Super+E"; };
      browser = mkOption { type = types.str; default = "Super+B"; };
    };

    # === Window & System ===
    window = {
      close = mkOption {
        type = types.listOf types.str;
        default = [ "Super+Q" "Super+Y" ];
      };
      overview = mkOption { type = types.str; default = "Super+O"; };
      inhibitShortcuts = mkOption { type = types.str; default = "Super+Escape"; };
    };

    # === Escape hatches ===
    extraNiri = mkOption {
      type = types.listOf (types.submodule {
        options = {
          key = mkOption { type = types.str; };
          action = mkOption { type = types.str; };
          args = mkOption {
            type = types.listOf types.str;
            default = [];
          };
        };
      });
      default = [];
      description = "Additional custom Niri keybindings";
    };

    extraXremap = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional xremap configuration";
    };
  };

  config = mkIf cfg.enable {
    # This module only defines options; consumers (niri.nix, xremap.nix) use them
  };
}

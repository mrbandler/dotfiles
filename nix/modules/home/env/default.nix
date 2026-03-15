{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.env;
in
{
  options.internal.env = {
    terminal = mkOption {
      type = types.str;
      default = "wezterm";
      description = "Default terminal emulator command ($TERMINAL)";
    };

    launcher = mkOption {
      type = types.str;
      default = "vicinae toggle";
      description = "Default app launcher command ($LAUNCHER)";
    };

    editor = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Console editor override ($EDITOR). Null uses system default.";
    };

    visual = mkOption {
      type = types.nullOr types.str;
      default = "zeditor";
      description = "Visual/GUI editor ($VISUAL)";
    };

    pager = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Pager override ($PAGER). Null uses system default.";
    };

    browser = mkOption {
      type = types.nullOr types.str;
      default = "zen";
      description = "Default web browser ($BROWSER)";
    };

    fileManager = mkOption {
      type = types.nullOr types.str;
      default = "nautilus";
      description = "Default file manager ($FILEMANAGER)";
    };
  };

  config = let
    envVars = filterAttrs (n: v: v != null) {
      TERMINAL = cfg.terminal;
      LAUNCHER = cfg.launcher;
      EDITOR = cfg.editor;
      VISUAL = cfg.visual;
      PAGER = cfg.pager;
      BROWSER = cfg.browser;
      FILEMANAGER = cfg.fileManager;
    };
  in {
    # For shell sessions
    home.sessionVariables = envVars;
    # For systemd user session (visible to Niri and other graphical apps)
    systemd.user.sessionVariables = envVars;
  };
}

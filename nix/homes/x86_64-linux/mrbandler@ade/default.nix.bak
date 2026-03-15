{
  lib,
  config,
  pkgs,
  ...
}:

{
  home.stateVersion = "25.11";
  home.username = "mrbandler";
  home.homeDirectory = "/home/mrbandler";

  internal = {
    browsers.firefox.enable = true;
    terminals.wezterm.enable = true;

    editors = {
      vscode.enable = true;
      zed.enable = true;
      helix.enable = true;
    };

    development = {
      nodejs = {
        enable = true;
        enableYarn = true;
        enablePnpm = true;
      };

      claude-code.enable = true;
    };

    theme = {
      enable = true;
      wallpaper = ../../../wallpapers/12-5/mocha-3840x1600.png;
      colorScheme = "catppuccin-mocha";
      polarity = "dark";
    };
  };
}

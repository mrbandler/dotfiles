{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

{
  imports = [
    ./desktop
  ];

  home.stateVersion = "25.11";
  home.username = "mrbandler";
  home.homeDirectory = "/home/mrbandler";
  home.packages = with pkgs; [
    jq
    just
    lazygit
  ];

  internal = {
    desktop.keybindings.enable = true;

    browsers = {
      firefox.enable = true;
      zen.enable = true;
    };

    terminals.wezterm.enable = true;
    security._1password = {
      enable = true;
      opnix = {
        enable = false;
        secrets = {};
      };
    };

    launchers = {
      vicinae.enable = true;
    };

    editors = {
      vscode.enable = true;
      zed.enable = true;
      helix.enable = true;
    };

    development = {
      vcs = {
        enable = true;
        signing.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2G7J57J+2prp4UH/oWhIk6q+/rrvIhlsCypkK6Ak+d";
      };

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
      colorScheme = "catppuccin-macchiato";
      polarity = "dark";
    };
  };
}

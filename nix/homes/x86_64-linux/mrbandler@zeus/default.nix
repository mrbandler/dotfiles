{
  ...
}:

{
  imports = [
    ./desktop
  ];

  home.stateVersion = "25.11";
  home.username = "mrbandler";
  home.homeDirectory = "/home/mrbandler";

  internal = {
    theme = {
      enable = true;
      wallpaper = ../../../wallpapers/12-5/mocha-3840x1600.png;
      colorScheme = "catppuccin-mocha";
      polarity = "dark";
    };

    maintenance = {
      enable = true;
      autoUpdate.enable = true;
    };

    security._1password = {
      enable = true;
      opnix = {
        enable = false;
        secrets = { };
      };
    };

    desktop = {
      core.keybindings.enable = true;
      launchers.vicinae.enable = true;
      fileManagers.nautilus.enable = true;
    };

    apps.web = {
      firefox.enable = true;
      zen.enable = true;
    };

    cli.terminals.wezterm.enable = true;

    development = {
      editors = {
        vscode.enable = true;
        zed.enable = true;
        helix.enable = true;
      };

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
  };
}

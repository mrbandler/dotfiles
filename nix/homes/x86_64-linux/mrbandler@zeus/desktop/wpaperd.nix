{ config, ... }:

{
  internal.desktop.wallpaper.wpaperd = {
    enable = true;

    mode = "fit";
    monitors = {
      DP-1 = {
        path = "${config.home.homeDirectory}/.dotfiles/nix/wallpapers/12-5/mocha-3840x1600.png";
        mode = "fit";
      };
      DP-2 = {
        path = "${config.home.homeDirectory}/.dotfiles/nix/wallpapers/16-9/mocha-1920x1080.png";
        mode = "fit";
      };
    };
  };
}

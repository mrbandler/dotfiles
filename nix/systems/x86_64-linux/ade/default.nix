{
  pkgs,
  inputs,
  system,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;

  internal = {
    core = {
      enable = true;
      networking = {
        hostName = "ade";
      };
      packages = {
        additionalPackages = with pkgs; [
          # Development tools
          vscode
          zed-editor
          nodejs_22
          claude-code
        ];
      };
    };

    desktop = {
      enable = true;
      plasma.enable = true;
      niri.enable = true;

      sddm = {
        enable = true;
        themePackage = pkgs.catppuccin-sddm.override {
          background = "${pkgs.internal.wallpapers}/share/wallpapers/12-5/mocha-3840x1600.png";
          loginBackground = true;
        };
      };

      gaming = {
        enable = true;
      };
    };
  };
}

{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";

  internal = {
    core = {
      enable = true;
      networking = {
        hostName = "zeus";
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

      # Display manager configuration
      sddm = {
        enable = true;
        themePackage = pkgs.catppuccin-sddm.override {
          background = "${pkgs.internal.wallpapers}/share/wallpapers/12-5/mocha-3840x1600.png";
          loginBackground = true;
        };
      };
    };
  };

  # Browser
  programs.firefox.enable = true;

  # Printing
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

}

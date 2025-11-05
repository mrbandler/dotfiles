{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";

  hardware.graphics.enable = true;

  internal = {
    core = {
      enable = true;
      networking = {
        hostName = "zeus";
      };
      env = {
        additionalPackages = with pkgs; [
          vscode
          nil
          nixpkgs-fmt
        ];
      };
    };

    desktop = {
      enable = true;
    };
  };

  programs.firefox.enable = true;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.printing.enable = true;
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

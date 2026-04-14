{
  pkgs,
  ...
}:

{
  imports = [
    ./thunderbird.nix
    ./vesktop.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
    whatsapp-electron
  ];
}

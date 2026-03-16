{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    uhk-agent
    spotify
    telegram-desktop
    whatsapp-electron
    vesktop
    claude-desktop
  ];
}

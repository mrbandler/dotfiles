{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    jq
    just
    lazygit
    uhk-agent
    spotify
    telegram-desktop
    whatsapp-electron
    vesktop
    claude-desktop
  ];
}

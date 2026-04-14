{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    uhk-agent
    solaar
    openrgb
    ddcutil
    ddcui
    system-config-printer
  ];
}

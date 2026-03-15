{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    ./keybinds.nix
    ./commands.nix
    ./xremap.nix
    ./niri.nix
    ./init.nix
    ./dms.nix
    ./wpaperd.nix
  ];
}

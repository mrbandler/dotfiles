{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    ./keybindings.nix
    ./xremap.nix
    ./niri.nix
    ./init.nix
    ./dms.nix
    ./wpaperd.nix
  ];
}

{
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./wpaperd.nix
    ./niri.nix
    ./dms.nix
  ];
}

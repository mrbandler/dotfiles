{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

{
  imports = [
    ./wpaperd.nix
    ./niri.nix
    ./dms.nix
  ];
}

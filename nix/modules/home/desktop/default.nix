{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    ./niri.nix
    ./wpaperd.nix
  ];
}

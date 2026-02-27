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
    ./dms.nix
    ./wpaperd.nix
  ];
}

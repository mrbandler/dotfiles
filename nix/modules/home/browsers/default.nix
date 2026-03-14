{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    ./firefox.nix
    ./zen.nix
  ];
}

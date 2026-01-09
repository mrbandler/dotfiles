{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    ./firefox.nix
  ];
}

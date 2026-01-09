{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    ./nodejs.nix
    ./claude-code.nix
  ];
}

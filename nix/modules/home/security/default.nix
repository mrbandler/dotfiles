{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    ./_1password.nix
  ];
}

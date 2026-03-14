{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    ./_1password.nix
  ];
}

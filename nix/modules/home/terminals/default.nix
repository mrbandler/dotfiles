{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    ./wezterm.nix
  ];
}

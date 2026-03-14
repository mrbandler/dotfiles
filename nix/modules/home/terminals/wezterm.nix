{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "terminals" "wezterm" ] [ "programs" "wezterm" ])
  ];
}

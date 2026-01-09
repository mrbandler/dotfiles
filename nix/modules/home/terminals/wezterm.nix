{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "terminals" "wezterm" ] [ "programs" "wezterm" ])
  ];
}

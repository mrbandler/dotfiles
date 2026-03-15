{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "terminals" "wezterm" ] [ "programs" "wezterm" ])
  ];
}

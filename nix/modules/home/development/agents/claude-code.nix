{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "claude-code" ] [ "programs" "claude-code" ])
  ];
}

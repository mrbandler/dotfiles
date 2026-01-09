{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "claude-code" ] [ "programs" "claude-code" ])
  ];
}

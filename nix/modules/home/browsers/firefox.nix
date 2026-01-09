{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "browsers" "firefox" ] [ "programs" "firefox" ])
  ];
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "editors" "helix" ] [ "programs" "helix" ])
  ];

  config = {
    programs.helix = {
    };
  };
}

{
  lib,
  config,
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

{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "editors" "helix" ] [ "programs" "helix" ])
  ];

  config = {
    programs.helix = {
    };
  };
}

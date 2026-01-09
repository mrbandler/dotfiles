{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "launchers" "vicinae" ] [ "programs" "vicinae" ])
  ];

  config = {
    programs.vicinae = {
    };
  };
}

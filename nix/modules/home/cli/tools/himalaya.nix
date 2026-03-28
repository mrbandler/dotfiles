{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "himalaya" ] [ "programs" "himalaya" ])
  ];

  config.programs.himalaya = {
    enable = true;
  };
}

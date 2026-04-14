{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "writing" "obsidian" ] [ "programs" "obsidian" ])
  ];

  config.programs.obsidian = {
    enable = true;
  };
}

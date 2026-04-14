{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "creative" "obs" ] [ "programs" "obs-studio" ])
  ];

  config.programs.obs-studio = {
    enable = true;
  };
}

{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.apps.gaming;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "gaming" "lutris" ] [ "programs" "lutris" ])
  ];

  config.programs.lutris = mkIf cfg.enable {
    enable = true;
  };
}

{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.apps.web.firefox;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "web" "firefox" ] [ "programs" "firefox" ])
  ];

  config = {
    stylix.targets.firefox.profileNames = [ config.home.username ];

    programs.firefox = {
    };
  };
}

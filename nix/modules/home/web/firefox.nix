{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.web.firefox;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "web" "firefox" ] [ "programs" "firefox" ])
  ];

  config = {
    stylix.targets.firefox.profileNames = [ config.home.username ];

    programs.firefox = {
    };
  };
}

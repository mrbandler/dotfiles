{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.browsers.firefox;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "browsers" "firefox" ] [ "programs" "firefox" ])
  ];

  config = {
    stylix.targets.firefox.profileNames = [ config.home.username ];

    programs.firefox = {
    };
  };
}

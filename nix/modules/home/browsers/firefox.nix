{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.browsers.firefox;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "browsers" "zen" ] [ "programs" "firefox" ])
  ];

  config = {
    programs.firefox = {
    };
  };
}

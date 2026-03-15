{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "desktop" "launchers" "vicinae" ] [ "programs" "vicinae" ])
  ];

  config = {
    internal.desktop.core.init.spawn = [ [ "vicinae" "server" ] ];

    programs.vicinae = {
    };
  };
}

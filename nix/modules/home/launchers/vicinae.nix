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
    internal.desktop.init.spawn = [ [ "vicinae" "server" ] ];

    programs.vicinae = {
    };
  };
}

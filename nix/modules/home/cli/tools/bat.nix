{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "bat" ] [ "programs" "bat" ])
  ];

  config.programs.bat = {
    enable = true;
  };
}

{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "fd" ] [ "programs" "fd" ])
  ];

  config.programs.fd = {
    enable = true;
    hidden = true;
  };
}

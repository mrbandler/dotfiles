{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "comms" "vesktop" ] [ "programs" "vesktop" ])
  ];

  config.programs.vesktop = {
    enable = true;
  };
}

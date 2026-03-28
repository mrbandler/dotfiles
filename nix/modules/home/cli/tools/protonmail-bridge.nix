{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "protonmail-bridge" ] [ "services" "protonmail-bridge" ])
  ];

  config.services.protonmail-bridge = {
    enable = true;
  };
}

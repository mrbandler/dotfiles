{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "comms" "thunderbird" ] [ "programs" "thunderbird" ])
  ];

  config.programs.thunderbird = {
    enable = true;
    profiles.${config.home.username} = {
      isDefault = true;
    };
  };
}

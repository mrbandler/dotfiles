{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "tealdeer" ] [ "programs" "tealdeer" ])
  ];

  config.programs.tealdeer = {
    enable = true;
    settings = {
      updates = {
        auto_update = true;
        auto_update_interval_hours = 168; # weekly
      };
    };
  };
}

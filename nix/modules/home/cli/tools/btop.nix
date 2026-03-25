{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "btop" ] [ "programs" "btop" ])
  ];

  config.programs.btop = {
    enable = true;
    settings = {
      update_ms = 1000;
      temp_scale = "celsius";
    };
  };
}

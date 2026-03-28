{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "khal" ] [ "programs" "khal" ])
  ];

  config.programs.khal = {
    enable = true;
    locale = {
      unicode_symbols = true;
      firstweekday = 0;
      weeknumbers = "left";
    };
  };
}

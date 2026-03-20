{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "shells" "bash" ] [ "programs" "bash" ])
  ];

  config.programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" ];
    historySize = 100000;
    historyFileSize = 100000;
  };
}

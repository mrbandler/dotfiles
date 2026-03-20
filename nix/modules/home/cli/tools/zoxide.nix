{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "zoxide" ] [ "programs" "zoxide" ])
  ];

  config.programs.zoxide = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}

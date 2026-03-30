{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "atuin" ] [ "programs" "atuin" ])
  ];

  config.programs.atuin = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}

{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "carapace" ] [ "programs" "carapace" ])
  ];

  config.programs.carapace = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}

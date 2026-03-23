{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "eza" ] [ "programs" "eza" ])
  ];

  config.programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    enableBashIntegration = config.programs.bash.enable;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}

{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "yazi" ] [ "programs" "yazi" ])
  ];

  config.programs.yazi = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableNushellIntegration = config.programs.nushell.enable;
    shellWrapperName = "y";
  };
}

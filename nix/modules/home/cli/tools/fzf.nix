{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "fzf" ] [ "programs" "fzf" ])
  ];

  config.programs.fzf = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    defaultCommand = mkIf config.programs.fd.enable "fd --type f";
  };
}

{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "multiplexers" "zellij" ] [ "programs" "zellij" ])
  ];

  config.programs.zellij = {
    enable = true;
    settings = {
      default_shell = "nu";
      show_startup_tips = false;
    };
  };
}

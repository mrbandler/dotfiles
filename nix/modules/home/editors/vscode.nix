{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "editors" "vscode" ] [ "programs" "vscode" ])
  ];

  config = {
    programs.vscode = {
    };
  };
}

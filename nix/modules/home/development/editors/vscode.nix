{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "editors" "vscode" ] [ "programs" "vscode" ])
  ];

  config = {
    programs.vscode = {
    };
  };
}

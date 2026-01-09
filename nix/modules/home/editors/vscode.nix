{
  lib,
  config,
  namespace,
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

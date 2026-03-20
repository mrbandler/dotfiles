{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "ripgrep" ] [ "programs" "ripgrep" ])
  ];

  config.programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
    ];
  };
}

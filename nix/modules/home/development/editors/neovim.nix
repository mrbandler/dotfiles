{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "editors" "neovim" ] [ "programs" "neovim" ])
  ];

  config = {
    programs.neovim = {
    };
  };
}

{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "nh" ] [ "programs" "nh" ])
  ];

  config.programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/.dotfiles/nix";
  };
}

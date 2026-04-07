{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
{
  imports = [
    ./delta.nix
    ./git-cliff.nix
  ];

  home.packages = optionals config.programs.gh.enable [
    pkgs.gh-enhance
  ];
}

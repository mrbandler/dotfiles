{
  lib,
  pkgs,
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
      enable = true;
      defaultEditor = false;
      vimAlias = true;
      viAlias = true;

      extraPackages = with pkgs; [
        gcc
        gnumake
      ];
    };

    xdg.configFile."nvim".source = ./config;
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.lazygit;
  yamlFormat = pkgs.formats.yaml {};
  deltaEnabled = config.programs.delta.enable or false;
  batEnabled = config.programs.bat.enable or false;
in
{
  options.internal.cli.tools.lazygit = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable lazygit Git TUI";
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = {};
      description = "Lazygit configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.lazygit ];

    internal.cli.tools.lazygit.settings = mkMerge [
      (mapAttrsRecursive (_: mkDefault) {
        gui = {
          showIcons = true;
          nerdFontsVersion = "3";
        };
      })
      (mkIf deltaEnabled {
        git.pagers = mkDefault [
          { command = "diff"; pager = "delta --paging=never"; }
        ];
      })
      (mkIf batEnabled {
        git.pagers = mkDefault [
          { command = "log"; pager = "bat --style=plain --paging=never"; }
        ];
      })
    ];

    xdg.configFile."lazygit/config.yml".source =
      yamlFormat.generate "lazygit-config.yml" cfg.settings;
  };
}

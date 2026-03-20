{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.development.tools.diffnav;
in
{
  options.internal.development.tools.diffnav = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.gh.enable;
      description = "Enable diffnav git diff pager";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.diffnav ];

    xdg.configFile."diffnav/config.yml".text = ''
      ui:
        showFileTree: true
        sideBySide: true
        icons: nerd-fonts-full
        colorFileNames: true
        showDiffStats: true
    '';
  };
}

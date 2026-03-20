{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.development.tools.gh-dash;
in
{
  options.internal.development.tools.gh-dash = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.gh.enable;
      description = "Enable gh-dash GitHub dashboard TUI";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.gh-dash ];

    xdg.configFile."gh-dash/config.yml".text = ''
      keybindings:
        prs:
          - key: d
            name: diffnav
            command: gh pr diff --repo {{.RepoName}} {{.PrNumber}} | diffnav
          - key: a
            name: enhance
            command: gh-enhance
    '';
  };
}

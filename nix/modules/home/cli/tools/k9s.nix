{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.k9s;
  yamlFormat = pkgs.formats.yaml {};
in
{
  options.internal.cli.tools.k9s = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable k9s Kubernetes TUI";
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = {};
      description = "K9s configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.k9s ];

    internal.cli.tools.k9s.settings = mapAttrsRecursive (_: mkDefault) {
      k9s = {
        refreshRate = 1;
        ui = {
          enableMouse = true;
        };
      };
    };

    xdg.configFile."k9s/config.yaml".source =
      yamlFormat.generate "k9s-config.yaml" cfg.settings;
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.glow;
  yamlFormat = pkgs.formats.yaml {};
in
{
  options.internal.cli.tools.glow = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable glow terminal markdown renderer";
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = {};
      description = "Glow configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.glow ];

    internal.cli.tools.glow.settings = mapAttrsRecursive (_: mkDefault) {
      style = "auto";
      width = 0;
      pager = true;
      mouse = true;
      showLineNumbers = true;
    };

    xdg.configFile."glow/glow.yml".source =
      yamlFormat.generate "glow-config.yml" cfg.settings;
  };
}

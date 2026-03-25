{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.lazydocker;
  yamlFormat = pkgs.formats.yaml {};
in
{
  options.internal.cli.tools.lazydocker = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable lazydocker Docker TUI";
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = {};
      description = "Lazydocker configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.lazydocker ];

    internal.cli.tools.lazydocker.settings = mapAttrsRecursive (_: mkDefault) {
    };

    xdg.configFile."lazydocker/config.yml".source =
      yamlFormat.generate "lazydocker-config.yml" cfg.settings;
  };
}

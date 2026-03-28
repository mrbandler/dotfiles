{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.xh;
  jsonFormat = pkgs.formats.json {};
in
{
  options.internal.cli.tools.xh = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable xh HTTP client (httpie replacement)";
    };

    settings = mkOption {
      type = jsonFormat.type;
      default = {};
      description = "xh configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.xh ];

    internal.cli.tools.xh.settings = mapAttrsRecursive (_: mkDefault) {
      default_options = [
        "--style=auto"
        "--pretty=all"
      ];
    };

    xdg.configFile."xh/config.json".source =
      jsonFormat.generate "xh-config.json" cfg.settings;
  };
}

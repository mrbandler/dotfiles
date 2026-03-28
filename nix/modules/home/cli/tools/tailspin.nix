{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.tailspin;
  tomlFormat = pkgs.formats.toml {};
in
{
  options.internal.cli.tools.tailspin = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tailspin log file highlighting";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = {};
      description = "Tailspin theme configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.tailspin ];

    internal.cli.tools.tailspin.settings = mapAttrsRecursive (_: mkDefault) {
      numbers.style = { fg = "cyan"; };
      dates = {
        date = { fg = "magenta"; };
        time = { fg = "blue"; };
        zone = { fg = "red"; };
      };
      urls = {
        http = { fg = "red"; };
        https = { fg = "green"; };
        host = { fg = "blue"; };
        path = { fg = "blue"; };
        query_params_key = { fg = "magenta"; };
        query_params_value = { fg = "cyan"; };
        symbols = { fg = "red"; };
      };
      json = {
        key = { fg = "yellow"; };
      };
    };

    xdg.configFile."tailspin/theme.toml".source =
      tomlFormat.generate "tailspin-theme.toml" cfg.settings;
  };
}

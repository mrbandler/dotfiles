{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.harlequin;
  tomlFormat = pkgs.formats.toml {};
in
{
  options.internal.cli.tools.harlequin = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable harlequin SQL IDE TUI";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = {};
      description = "Harlequin configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (harlequin.overridePythonAttrs (old: {
        pythonRelaxDeps = (old.pythonRelaxDeps or []) ++ [ "tomlkit" ];
      }))
      python313Packages.harlequin-postgres
    ];

    internal.cli.tools.harlequin.settings = mapAttrsRecursive (_: mkDefault) {
      default_profile = "local";
      profiles.local = {
        adapter = "duckdb";
        theme = "catppuccin-mocha";
        limit = 100000;
        keymap_name = [ "vscode" ];
      };
    };

    xdg.configFile."harlequin/config.toml".source =
      tomlFormat.generate "harlequin-config.toml" cfg.settings;
  };
}

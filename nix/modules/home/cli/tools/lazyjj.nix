{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.lazyjj;
  tomlFormat = pkgs.formats.toml {};
in
{
  options.internal.cli.tools.lazyjj = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable lazyjj Jujutsu VCS TUI";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = {};
      description = "Lazyjj configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.lazyjj ];

    internal.cli.tools.lazyjj.settings = mapAttrsRecursive (_: mkDefault) {
    };

    xdg.configFile."lazyjj/config.toml".source =
      tomlFormat.generate "lazyjj-config.toml" cfg.settings;
  };
}

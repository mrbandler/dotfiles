{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.tv;
in
{
  options.internal.cli.tools.tv = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable television fuzzy finder";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.television ];

    xdg.configFile."television/config.toml".text = ''
    '';
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.development.tools.git-cliff;
in
{
  options.internal.development.tools.git-cliff = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable git-cliff changelog generator";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.git-cliff ];

    xdg.configFile."git-cliff/cliff.toml".text = ''
    '';
  };
}

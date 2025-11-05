{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop;
in
{
  imports = [
    ./sddm.nix
  ];

  options.${namespace}.desktop = {
    enable = mkEnableOption "enable desktop";
  };

  config = mkIf cfg.enable {
    security.polkit.enable = true;
  };
}

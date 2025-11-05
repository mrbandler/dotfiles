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

  options.${namespace}.desktop.sddm = {
  };

  config = mkIf cfg.enable {
  };
}

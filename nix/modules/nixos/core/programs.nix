{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.core.programs;
in
{
  options.${namespace}.core.programs = {
    enable = lib.mkEnableOption "core programs";
  };

  config = lib.mkIf cfg.enable {
  };
}

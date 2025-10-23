{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.core.services;
in
{
  options.${namespace}.core.services = {
    enable = lib.mkEnableOption "core services";
  };

  config = lib.mkIf cfg.enable {
  };
}

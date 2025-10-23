{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.core.environment;
in
{
  options.${namespace}.core.environment = {
    enable = lib.mkEnableOption "core environment";
  };

  config = lib.mkIf cfg.enable {
  };
}

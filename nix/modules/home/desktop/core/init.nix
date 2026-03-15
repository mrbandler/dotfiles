{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.desktop.core.init;
in
{
  options.internal.desktop.core.init = {
    spawn = mkOption {
      type = types.listOf (types.listOf types.str);
      default = [];
      description = "Commands to spawn at Niri startup";
    };
  };
}

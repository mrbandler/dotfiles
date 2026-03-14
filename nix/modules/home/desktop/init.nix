{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.desktop.init;
in
{
  options.internal.desktop.init = {
    spawn = mkOption {
      type = types.listOf (types.listOf types.str);
      default = [];
      description = "Commands to spawn at Niri startup";
    };
  };
}

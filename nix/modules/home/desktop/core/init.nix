{
  lib,
  ...
}:

with lib;
{
  options.internal.desktop.core.init = {
    spawn = mkOption {
      type = types.listOf (types.listOf types.str);
      default = [ ];
      description = "Commands to spawn at Niri startup";
    };
  };
}

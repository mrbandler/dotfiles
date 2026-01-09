{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  desktopCfg = config.${namespace}.desktop;
in
{
  config = mkIf desktopCfg.enable {
    # Enable GVFS for virtual filesystem support (network shares, trash, etc.)
    services.gvfs.enable = true;

    # Enable thumbnail generation service
    services.tumbler.enable = true;
  };
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.virtualization;
  desktopCfg = config.${namespace}.desktop;
in
{
  imports = [
    ./docker.nix
    ./podman.nix
    ./libvirt.nix
    ./virtualbox.nix
    ./waydroid.nix
  ];

  options.${namespace}.desktop.services.virtualization = {
    enable = mkEnableOption "virtualization services";
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # Common virtualization configuration can go here
  };
}

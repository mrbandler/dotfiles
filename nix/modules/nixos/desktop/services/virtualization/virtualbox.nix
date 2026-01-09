{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.virtualization.virtualbox;
  virtCfg = config.${namespace}.desktop.services.virtualization;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.services.virtualization.virtualbox = {
    enable = mkEnableOption "VirtualBox";

    extensionPack = mkOption {
      type = types.bool;
      default = false;
      description = "Enable VirtualBox Extension Pack (requires accepting Oracle license).";
    };
  };

  config = mkIf (desktopCfg.enable && virtCfg.enable && cfg.enable) {
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = cfg.extensionPack;
    };

    users.groups.vboxusers = { };
    users.users.${config.${namespace}.core.user.name}.extraGroups = [ "vboxusers" ];
  };
}

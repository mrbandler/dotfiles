{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.services.virtualization.libvirt;
  virtCfg = config.${namespace}.desktop.services.virtualization;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.services.virtualization.libvirt = {
    enable = mkEnableOption "libvirt/QEMU/KVM";

    gui = mkOption {
      type = types.bool;
      default = true;
      description = "Enable virt-manager GUI.";
    };
  };

  config = mkIf (desktopCfg.enable && virtCfg.enable && cfg.enable) {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };

    programs.virt-manager.enable = mkIf cfg.gui true;

    users.groups.libvirtd = { };
    users.users.${config.${namespace}.core.user.name}.extraGroups = [ "libvirtd" ];
  };
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  imports = [
    ./nix.nix
    ./boot.nix
    ./env.nix
    ./packages.nix
    ./user.nix
    ./networking.nix
    ./locale.nix
    ./security.nix
    ./documentation.nix
    ./services.nix
    ./ssh.nix
    ./firmware.nix
    ./logging.nix
    ./swap.nix
    ./kernel.nix
  ];

  options.${namespace}.core = {
    enable = mkEnableOption "enable core";
  };

  config = mkIf cfg.enable {
    hardware = {
      enableAllFirmware = mkDefault true;
      cpu.amd.updateMicrocode = mkDefault true;
      cpu.intel.updateMicrocode = mkDefault true;
    };

    virtualisation.libvirtd.enable = mkDefault false;
  };
}

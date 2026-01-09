{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.kernel = {
    variant = mkOption {
      type = types.enum [
        "stable"
        "latest"
        "hardened"
        "latest-hardened"
      ];
      default = "stable";
      description = ''
        Linux kernel variant to use:
        - stable: Latest LTS kernel (default, recommended for most users)
        - latest: Latest stable kernel (newest features, may have compatibility issues)
        - hardened: LTS kernel with additional security patches
        - latest-hardened: Latest kernel with security patches

        Note: Hardened kernels may lag ~1 week behind upstream.
        If using ZFS, stick with 'stable' for best compatibility.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.kernelPackages = mkDefault (
      if cfg.kernel.variant == "latest" then
        pkgs.linuxPackages_latest
      else if cfg.kernel.variant == "hardened" then
        pkgs.linuxPackages_hardened
      else if cfg.kernel.variant == "latest-hardened" then
        pkgs.linuxPackages_latest_hardened
      else
        pkgs.linuxPackages # stable LTS
    );
  };
}

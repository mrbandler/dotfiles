{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.gpu.intel;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.gpu.intel = {
    enable = mkEnableOption "Intel GPU support";

    driver = mkOption {
      type = types.enum [
        "i915"
        "xe"
      ];
      default = "i915";
      description = "Intel GPU kernel driver (xe for newer GPUs).";
    };

    vaapi = {
      driver = mkOption {
        type = types.enum [
          "iHD"
          "i965"
        ];
        default = "iHD";
        description = "VA-API driver (iHD for newer, i965 for older GPUs).";
      };
    };

    vpl = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Intel oneVPL for hardware video processing.";
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    hardware.graphics.extraPackages = with pkgs; [
      (mkIf (cfg.vaapi.driver == "iHD") intel-media-driver)
      (mkIf (cfg.vaapi.driver == "i965") intel-vaapi-driver)
      (mkIf cfg.vpl vpl-gpu-rt)
    ];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = cfg.vaapi.driver;
    };

    boot.kernelParams = mkIf (cfg.driver == "xe") [
      "i915.force_probe=!*"
      "xe.force_probe=*"
    ];
  };
}

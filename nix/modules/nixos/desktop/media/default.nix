{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.media;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.media = {
    hardwareAcceleration = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable hardware video acceleration.";
      };

      intel = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Intel hardware acceleration (VA-API).";
      };

      amd = mkOption {
        type = types.bool;
        default = false;
        description = "Enable AMD hardware acceleration (VA-API/VDPAU).";
      };

      nvidia = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA hardware acceleration (NVDEC/NVENC).";
      };
    };

    codecs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable additional media codecs.";
      };

      openh264 = mkOption {
        type = types.bool;
        default = true;
        description = "Enable OpenH264 codec.";
      };
    };

    gstreamer = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable GStreamer with additional plugins.";
      };
    };
  };

  config = mkIf desktopCfg.enable {
    hardware.graphics = mkIf cfg.hardwareAcceleration.enable {
      enable = true;
      enable32Bit = true;

      extraPackages =
        with pkgs;
        [ ]
        # Intel
        ++ optionals cfg.hardwareAcceleration.intel [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for some apps)
          vpl-gpu-rt # oneVPL for newer GPUs
        ]
        # AMD
        ++ optionals cfg.hardwareAcceleration.amd [
          mesa
          libvdpau-va-gl
        ]
        # NVIDIA
        ++ optionals cfg.hardwareAcceleration.nvidia [
          nvidia-vaapi-driver
        ];

      extraPackages32 =
        with pkgs.pkgsi686Linux;
        [ ]
        ++ optionals cfg.hardwareAcceleration.intel [
          intel-media-driver
          intel-vaapi-driver
        ]
        ++ optionals cfg.hardwareAcceleration.amd [
          mesa
          libvdpau-va-gl
        ];
    };

    # Set environment variables for hardware acceleration
    environment.sessionVariables = mkIf cfg.hardwareAcceleration.enable (mkMerge [
      (mkIf cfg.hardwareAcceleration.intel {
        LIBVA_DRIVER_NAME = "iHD"; # or "i965" for older GPUs
      })
      (mkIf cfg.hardwareAcceleration.amd {
        LIBVA_DRIVER_NAME = "radeonsi";
      })
      (mkIf cfg.hardwareAcceleration.nvidia {
        LIBVA_DRIVER_NAME = "nvidia";
        NVD_BACKEND = "direct";
      })
    ]);

    # Media codecs and GStreamer
    environment.systemPackages =
      with pkgs;
      [ ]
      # Media codecs
      ++ optionals cfg.codecs.enable (optionals cfg.codecs.openh264 [ openh264 ])
      # GStreamer with plugins
      ++ optionals cfg.gstreamer.enable [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-vaapi
      ];
  };
}

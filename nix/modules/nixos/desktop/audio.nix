{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.audio;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.audio = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable audio support.";
    };

    backend = mkOption {
      type = types.enum [
        "pipewire"
        "pulseaudio"
      ];
      default = "pipewire";
      description = "Audio backend to use.";
    };

    pipewire = {
      alsa = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ALSA support.";
      };

      alsa32Bit = mkOption {
        type = types.bool;
        default = true;
        description = "Enable 32-bit ALSA support.";
      };

      pulse = mkOption {
        type = types.bool;
        default = true;
        description = "Enable PulseAudio compatibility layer.";
      };

      jack = mkOption {
        type = types.bool;
        default = false;
        description = "Enable JACK support.";
      };

      lowLatency = mkOption {
        type = types.bool;
        default = false;
        description = "Enable low-latency audio configuration.";
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # Enable rtkit for real-time scheduling
    security.rtkit.enable = true;

    # PipeWire configuration
    services.pipewire = mkIf (cfg.backend == "pipewire") {
      enable = true;
      alsa.enable = mkDefault cfg.pipewire.alsa;
      alsa.support32Bit = mkDefault cfg.pipewire.alsa32Bit;
      pulse.enable = mkDefault cfg.pipewire.pulse;
      jack.enable = mkDefault cfg.pipewire.jack;

      # Low-latency configuration
      extraConfig.pipewire = mkIf cfg.pipewire.lowLatency {
        "92-low-latency" = {
          context.properties = {
            default.clock.rate = 48000;
            default.clock.quantum = 256;
            default.clock.min-quantum = 256;
            default.clock.max-quantum = 256;
          };
        };
      };
    };

    # PulseAudio configuration
    services.pulseaudio = mkIf (cfg.backend == "pulseaudio") {
      enable = true;
      support32Bit = true;
    };
  };
}

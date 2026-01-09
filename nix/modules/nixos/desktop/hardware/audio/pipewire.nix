{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.audio.pipewire;
  audioCfg = config.${namespace}.desktop.hardware.audio;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.audio.pipewire = {
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

    lowLatency = {
      enable = mkEnableOption "low-latency audio configuration";

      quantum = mkOption {
        type = types.int;
        default = 256;
        description = "Audio buffer size (lower = less latency, more CPU).";
      };
    };
  };

  config = mkIf (desktopCfg.enable && audioCfg.backend == "pipewire") {
    services.pipewire = {
      enable = true;
      alsa.enable = cfg.alsa;
      alsa.support32Bit = cfg.alsa32Bit;
      pulse.enable = cfg.pulse;
      jack.enable = cfg.jack;

      extraConfig.pipewire = mkIf cfg.lowLatency.enable {
        "92-low-latency" = {
          context.properties = {
            default.clock.rate = 48000;
            default.clock.quantum = cfg.lowLatency.quantum;
            default.clock.min-quantum = cfg.lowLatency.quantum;
            default.clock.max-quantum = cfg.lowLatency.quantum;
          };
        };
      };
    };
  };
}

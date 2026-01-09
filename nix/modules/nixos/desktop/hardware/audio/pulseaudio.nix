{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.audio.pulseaudio;
  audioCfg = config.${namespace}.desktop.hardware.audio;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.audio.pulseaudio = {
    support32Bit = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 32-bit PulseAudio support.";
    };
  };

  config = mkIf (desktopCfg.enable && audioCfg.backend == "pulseaudio") {
    services.pulseaudio = {
      enable = true;
      support32Bit = cfg.support32Bit;
    };
  };
}

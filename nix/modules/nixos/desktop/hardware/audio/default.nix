{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  desktopCfg = config.${namespace}.desktop;
in
{
  imports = [
    ./pipewire.nix
    ./pulseaudio.nix
  ];

  options.${namespace}.desktop.hardware.audio = {
    backend = mkOption {
      type = types.enum [
        "pipewire"
        "pulseaudio"
      ];
      default = "pipewire";
      description = "Audio backend to use.";
    };
  };

  config = mkIf desktopCfg.enable {
    security.rtkit.enable = true;
  };
}

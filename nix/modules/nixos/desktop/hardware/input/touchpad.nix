{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.input.touchpad;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.input.touchpad = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable touchpad support.";
    };

    naturalScrolling = mkOption {
      type = types.bool;
      default = false;
      description = "Enable natural scrolling (reverse direction).";
    };

    tapToClick = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tap-to-click.";
    };

    twoFingerScroll = mkOption {
      type = types.bool;
      default = true;
      description = "Enable two-finger scrolling.";
    };

    disableWhileTyping = mkOption {
      type = types.bool;
      default = true;
      description = "Disable touchpad while typing.";
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    services.libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = cfg.naturalScrolling;
        tapping = cfg.tapToClick;
        scrollMethod = mkIf cfg.twoFingerScroll "twofinger";
        disableWhileTyping = cfg.disableWhileTyping;
      };
    };
  };
}

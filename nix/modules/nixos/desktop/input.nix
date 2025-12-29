{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.input;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.input = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable input device configuration.";
    };

    touchpad = {
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

    wacom = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Wacom tablet support.";
      };
    };

    gameController = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable game controller support.";
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # libinput for touchpad and input devices
    services.libinput = mkIf cfg.touchpad.enable {
      enable = true;
      touchpad = {
        naturalScrolling = cfg.touchpad.naturalScrolling;
        tapping = cfg.touchpad.tapToClick;
        scrollMethod = mkIf cfg.touchpad.twoFingerScroll "twofinger";
        disableWhileTyping = cfg.touchpad.disableWhileTyping;
      };
    };

    # Wacom tablet support
    services.xserver.wacom.enable = mkIf cfg.wacom.enable true;

    # Game controller support (SDL, udev rules)
    hardware.xone.enable = mkIf cfg.gameController.enable true;
    hardware.xpadneo.enable = mkIf cfg.gameController.enable true;
  };
}

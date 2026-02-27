{ config, ... }:

{
  internal.desktop.dms = {
    enable = true;

    theme = {
      name = "catppuccin";
      flavor = "macchiato";
      accent = "sapphire";
    };

    session = {
      weatherLocation = "Arnstorf, 94424";
      weatherCoordinates = "48.5615685,12.8218254";
      perMonitorWallpaper = true;
      monitorWallpapers = {
        DP-1 = "${config.home.homeDirectory}/.dotfiles/nix/wallpapers/12-5/mocha-3840x1600.png";
        DP-2 = "${config.home.homeDirectory}/.dotfiles/nix/wallpapers/16-9/mocha-1920x1080.png";
      };
      monitorWallpaperFillModes = {
        DP-2 = "Fit";
        DP-1 = "Fit";
      };
    };

    settings = {
      controlCenterWidgets = [
        {
          enabled = true;
          id = "volumeSlider";
          width = 50;
        }
        {
          id = "inputVolumeSlider";
          enabled = true;
          width = 50;
        }
        {
          enabled = true;
          id = "audioInput";
          width = 50;
        }
        {
          enabled = true;
          id = "audioOutput";
          width = 50;
        }
        {
          enabled = true;
          id = "bluetooth";
          width = 50;
        }
        {
          enabled = true;
          id = "wifi";
          width = 50;
        }
        {
          enabled = true;
          id = "nightMode";
          width = 50;
        }
        {
          id = "doNotDisturb";
          enabled = true;
          width = 50;
        }
      ];

      barConfigs = [
        {
          id = "primary";
          name = "Primary Bar";
          enabled = true;
          position = 0;
          screenPreferences = [ "DP-1" ];

          leftWidgets = [
            "workspaceSwitcher"
            {
              id = "focusedWindow";
              enabled = true;
              focusedWindowCompactMode = false;
            }
          ];

          centerWidgets = [
            {
              id = "music";
              enabled = true;
              mediaSize = 1;
            }
            {
              id = "clock";
              enabled = true;
            }
            {
              id = "weather";
              enabled = true;
            }
            {
              id = "separator";
              enabled = true;
            }
            {
              id = "dankPomodoroTimer";
              enabled = true;
            }
            {
              id = "privacyIndicator";
              enabled = true;
            }
          ];

          rightWidgets = [
            {
              id = "systemTray";
              enabled = true;
            }
            {
              id = "claudeCodeUsage";
              enabled = true;
            }
            {
              id = "cpuUsage";
              enabled = true;
              minimumWidth = true;
            }
            {
              id = "memUsage";
              enabled = true;
              minimumWidth = true;
              showInGb = false;
            }
            {
              id = "nixMonitor";
              enabled = true;
            }
            {
              id = "sshMonitor";
              enabled = true;
            }
            {
              id = "vpn";
              enabled = true;
            }
            {
              id = "keyboard_layout_name";
              enabled = true;
              keyboardLayoutNameCompactMode = false;
            }
            {
              id = "battery";
              enabled = true;
            }
            {
              id = "controlCenterButton";
              enabled = true;
              showNetworkIcon = true;
              showBluetoothIcon = true;
              showAudioIcon = true;
              showAudioPercent = true;
              showVpnIcon = false;
              showBrightnessIcon = false;
              showBrightnessPercent = false;
              showMicIcon = false;
              showMicPercent = false;
              showBatteryIcon = false;
              showPrinterIcon = false;
            }
            {
              id = "notificationButton";
              enabled = true;
            }
            {
              id = "powerMenuButton";
              enabled = true;
            }
          ];

          spacing = 10;
          innerPadding = 0;
          widgetPadding = 10;
        }
        {
          id = "secondary";
          name = "Secondary Bar";
          enabled = true;
          position = 0;
          screenPreferences = [ "DP-2" ];

          leftWidgets = [
            {
              id = "workspaceSwitcher";
              enabled = true;
            }
            {
              id = "focusedWindow";
              enabled = true;
              focusedWindowCompactMode = false;
            }
          ];

          centerWidgets = [
            {
              id = "clock";
              enabled = true;
            }
            {
              id = "separator";
              enabled = true;
            }
            {
              id = "dankPomodoroTimer";
              enabled = true;
            }
            {
              id = "privacyIndicator";
              enabled = true;
            }
          ];

          rightWidgets = [
            {
              id = "claudeCodeUsage";
              enabled = true;
            }
            {
              id = "keyboard_layout_name";
              enabled = true;
              keyboardLayoutNameCompactMode = false;
            }
          ];

          spacing = 10;
          innerPadding = 0;
          widgetPadding = 10;
        }
      ];
    };
  };
}

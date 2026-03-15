{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "desktop" "shell" "dms" ] [ "programs" "dank-material-shell" ])
  ];

  config = {
    programs.dank-material-shell = {
      systemd.enable = false;
      enableDynamicTheming = false;

      niri = {
        enableSpawn = true;
        includes = {
            enable = true;
            override = true;
            originalFileName = "hm";
          };
      };

      plugins = {
        dankPomodoroTimer = {
          enable = true;
          settings = {
            workDuration = "50";
            shortBreakDuration = "10";
            longBreakDuration = "20";
            autoStartBreaks = true;
            autoStartPomodoros = true;
            autoSetDND = true;
          };
        };


        dankBatteryAlerts = {
          enable = true;
          settings = {
            criticalThreshold = 10;
            criticalTitle = "Critical Battery Level";
            criticalMessage = "Battery at \${level}% - Connect charger immediately!";
            enableWarningAlert = true;
            warningThreshold = 20;
            warningTitle = "Low Battery";
            warningMessage = "Battery at \${level}% - Consider charging soon";
          };
        };

        nixMonitor = {
          enable = true;
          settings = {
            showGenerations = true;
            showStoreSize = true;
            gcThresholdGB = 50;
            checkUpdates = true;
            updateCheckInterval = 3570;
            updateInterval = 300;
          };
        };

        dankActions.enable = true;
        sshMonitor.enable = true;
        claudeCodeUsage.enable = true;
      };

      clipboardSettings = {
        maxHistory = 25;
        maxEntrySize = 5242880;
        autoClearDays = 1;
        clearAtStartup = true;
        disabled = false;
        disableHistory = false;
        disablePersist = true;
      };

      session = {
        isLightMode = false;
        doNotDisturb = true;
      };

      settings = {
        widgetBackgroundColor = "s";
        cornerRadius = 5;

        use24HourClock = true;
        showSeconds = true;

        controlCenterShowNetworkIcon = false;
        controlCenterShowBluetoothIcon = false;
        controlCenterShowAudioIcon = false;
        controlCenterShowAudioPercent = false;

        showPrivacyButton = true;

        showWorkspaceName = true;
        showOccupiedWorkspacesOnly = false;

        workspaceColorMode = "default";
        workspaceOccupiedColorMode = "none";
        workspaceUnfocusedColorMode = "sch";
        workspaceUrgentColorMode = "default";
        workspaceNameIcons = {};

        scrollTitleEnabled = false;
        keyboardLayoutNameCompactMode = false;
        appIdSubstitutions = [
          {
            pattern = "Spotify";
            replacement = "spotify";
            type = "exact";
          }
          {
            pattern = "beepertexts";
            replacement = "beeper";
            type = "exact";
          }
          {
            pattern = "home assistant desktop";
            replacement = "homeassistant-desktop";
            type = "exact";
          }
          {
            pattern = "com.transmissionbt.transmission";
            replacement = "transmission-gtk";
            type = "contains";
          }
          {
            pattern = "^steam_app_(\\d+)$";
            replacement = "steam_icon_$1";
            type = "regex";
          }
        ];
        centeringMode = "index";
        clockDateFormat = "ddd d MMM";
        lockDateFormat = "ddd d MMM";
        mediaSize = 1;

        browserPickerViewMode = "list";
        browserUsageHistory = {};
        appPickerViewMode = "list";
        filePickerUsageHistory = {};

        useAutoLocation = false;
        weatherEnabled = true;

        acMonitorTimeout = 1800;
        acLockTimeout = 900;
        acSuspendTimeout = 3600;
        acSuspendBehavior = 0;
        acProfileName = "";

        lockBeforeSuspend = true;

        lockScreenActiveMonitor = "DP-1";
        lockScreenInactiveColor = "#0f0f17";
        lockScreenNotificationMode = 1;

        osdAlwaysShowValue = true;
        powerMenuDefaultAction = "lock";

        niriOutputSettings = {
          DP-1 = {
            focusAtStartup = true;
            layout = null;
          };
        };
        displayProfiles = {
          niri = {
            default = {
              id = "default";
              name = "Default";
              outputSet = [
                "DP-1"
                "DP-2"
              ];
              createdAt = 0;
              updatedAt = 0;
            };
          };
        };
        activeDisplayProfile = {
          niri = "default";
        };
        displayProfileAutoSelect = true;
        displayShowDisconnected = true;
        displaySnapToEdge = true;
      };
    };
  };
}

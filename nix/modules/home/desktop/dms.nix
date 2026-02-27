{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

with lib;
let
  cfg = config.programs.dank-material-shell;
  colors = config.lib.stylix.colors;

  # Available themes from dms-plugin-registry (dynamically read from flake)
  availableThemes = builtins.attrNames (
    lib.filterAttrs (name: type: type == "directory")
      (builtins.readDir "${inputs.dms-plugin-registry}/themes")
  );

  themeSettings = if cfg.theme.name != null then {
    currentThemeName = "custom";
    currentThemeCategory = "registry";
    customThemeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/themes/${cfg.theme.name}/theme.json";
    registryThemeVariants = {
      ${cfg.theme.name} = {
        dark = lib.filterAttrs (n: v: v != null) {
          flavor = cfg.theme.flavor;
          accent = cfg.theme.accent;
        };
      };
    };
  } else {};
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "desktop" "dms" ] [ "programs" "dank-material-shell" ])
  ];

  options.programs.dank-material-shell.theme = {
    name = mkOption {
      type = types.nullOr (types.enum availableThemes);
      default = null;
      description = "Theme name from the DMS plugin registry. Set to null to use default theming.";
      example = "catppuccin";
    };

    flavor = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Theme flavor/variant (theme-specific, e.g., 'macchiato' for catppuccin).";
      example = "macchiato";
    };

    accent = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Accent color for the theme (theme-specific, e.g., 'blue' for catppuccin).";
      example = "blue";
    };
  };

  config = {
    xdg.configFile."DankMaterialShell/themes/${cfg.theme.name}/theme.json" = mkIf (cfg.theme.name != null) {
      source = "${inputs.dms-plugin-registry}/themes/${cfg.theme.name}/theme.json";
    };

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
        dankPomodoroTimer.enable = true;
        dankActions.enable = true;
        dankBatteryAlerts.enable = true;
        nixMonitor.enable = true;
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

      settings = themeSettings // {
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

        fontFamily = "Inter Variable";
        monoFontFamily = "JetBrainsMono Nerd Font";
        fontWeight = 400;
        fontScale = 1;

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

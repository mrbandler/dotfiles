{ den, inputs, config, ... }:
let
  secretPaths = config.programs.onepassword-secrets.secretPaths or {};
  mkSecret = config.lib.opnix.mkSecret or (_: _: {});
in
{
  den.hosts.x86_64-linux.zeus.users.mrbandler = {};

  # =========================================================================
  # Host aspect
  # =========================================================================
  den.aspects.zeus = {
    includes = with den.aspects; [
      # Core
      core
      security
      theme
      maintenance

      # Desktop
      desktop
      desktop-niri
      desktop-dms
      desktop-keybindings
      desktop-input
      desktop-launchers
      desktop-file-managers

      # Hardware
      hardware-gpu-amd
      hardware-audio
      hardware-displays

      # Features
      gaming
      virtualization

      # Development
      development
      development-editors
      development-agents

      # CLI (includes shells, tools, terminal, multiplexers)
      cli

      # Apps
      apps-web
      apps-comms
      apps-creative
      apps-media
      apps-writing
      apps-storage
      apps-devices

      # Accounts
      accounts-email
      accounts-calendar
    ];

    # --- Zeus NixOS-specific config (merges with shared aspects) ---
    nixos = { lib, ... }: {
      imports = [
        ./hardware-configuration.nix
        ./disko.nix
        inputs.disko.nixosModules.default
      ];

      # UHK keyboard support
      hardware.keyboard.uhk.enable = true;

      # Hostname
      networking.hostName = "zeus";

      # Additional nix caches
      nix.settings.substituters = lib.mkForce [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://niri.cachix.org"
      ];

      # DMS greeter config
      programs.dank-material-shell.greeter = {
        compositor.name = "niri";
        configHome = "/home/mrbandler";
      };

      # GameMode AMD GPU tuning
      programs.gamemode.settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };

      # PipeWire jack + low latency
      services.pipewire = {
        jack.enable = true;
        extraConfig.pipewire."92-low-latency" = {
          context.properties = {
            default.clock.rate = 48000;
            default.clock.quantum = 256;
            default.clock.min-quantum = 256;
            default.clock.max-quantum = 256;
          };
        };
      };

      # Media HW acceleration for AMD
      hardware.graphics.extraPackages = with (import inputs.nixpkgs { system = "x86_64-linux"; }); [
        mesa
        libvdpau-va-gl
      ];

      # Wacom tablet
      services.xserver.wacom.enable = true;

      # Virtualization enables
      virtualisation.docker.enable = true;
      virtualisation.libvirtd.enable = true;
    };

    # --- Push user-level config to all users on this host ---
    provides.to-users.homeManager = { lib, config, pkgs, ... }:
      let
        secretPaths = config.programs.onepassword-secrets.secretPaths or {};
      in
      {
        home.username = "mrbandler";
        home.homeDirectory = "/home/mrbandler";

        # --- Theme ---
        stylix = {
          image = ../../../wallpapers/12-5/mocha-3840x1600.png;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          polarity = "dark";
        };

        # --- Niri monitor outputs ---
        programs.niri.settings.outputs = {
          DP-1 = {
            mode = { width = 3840; height = 1600; refresh = 74.977; };
            position = { x = 0; y = 0; };
            variable-refresh-rate = true;
          };
          DP-2 = {
            mode = { width = 1920; height = 1080; refresh = 60.000; };
            position = { x = (3840 - 1920) / 2; y = 1600; };
            variable-refresh-rate = true;
          };
        };

        # --- Keybindings ---
        internal.desktop.core = {
          keybindings.enable = true;
          commands.scratchTerminal.command = "zellij attach --create scratch";

          workspaces = [
            { name = "1"; monitor = "DP-2"; }
            { name = "2"; monitor = "DP-2"; }
            { name = "3"; monitor = "DP-2"; }
          ];

          windowRules = [
            { matches = [{ appId = "^zen"; }]; excludes = [{ title = "Zen Browser Private Browsing"; }]; properties = { open-on-workspace = "1"; default-column-width.proportion = 1.0; }; }
            { matches = [{ title = "^Claude$"; }]; properties = { open-on-workspace = "1"; default-column-width.proportion = 1.0; }; }
            { matches = [{ title = "^WhatsApp"; }]; properties = { open-on-workspace = "2"; default-column-width.proportion = 0.5; }; }
            { matches = [{ appId = "^org\\.telegram\\.desktop$"; }]; properties = { open-on-workspace = "2"; default-column-width.proportion = 0.5; }; }
            { matches = [{ appId = "^vesktop$"; }]; properties = { open-on-workspace = "2"; default-column-width.proportion = 1.0; }; }
            { matches = [{ appId = "^spotify$"; }]; properties = { open-on-workspace = "3"; default-column-width.proportion = 1.0; }; }
            { matches = [{ appId = "^zen"; title = "^Picture-in-Picture$"; }]; properties = { open-floating = true; }; }
            { matches = [{ appId = "^org\\.quickshell$"; title = "^System Monitor$"; }]; properties = { open-floating = true; default-column-width.proportion = 0.5; default-window-height.proportion = 0.75; }; }
          ];

          init.spawn = [
            [ (builtins.toString (pkgs.writeShellScript "workspace-startup" ''
              waitForWindow() {
                timeout=17
                while ! niri msg windows | grep -q "App ID: \"$1\""; do
                  sleep 0.3
                  timeout=$((timeout - 1))
                  if [ $timeout -le 0 ]; then break; fi
                done
              }
              waitForTitle() {
                timeout=17
                while ! niri msg windows | grep -q "Title: \"$1"; do
                  sleep 0.3
                  timeout=$((timeout - 1))
                  if [ $timeout -le 0 ]; then break; fi
                done
              }
              zen-beta --profile $HOME/.config/zen/mrbandler &
              waitForWindow "zen-beta"
              claude-desktop &
              waitForTitle "Claude"
              whatsapp-electron &
              waitForTitle "WhatsApp"
              WA_ID=$(niri msg windows | grep -B1 'Title: "WhatsApp' | head -1 | grep -oP '\d+')
              if [ -n "$WA_ID" ]; then
                niri msg action focus-window --id "$WA_ID"
                niri msg action move-column-to-workspace 2 --focus false
              fi
              Telegram &
              waitForWindow "org.telegram.desktop"
              vesktop &
              waitForWindow "vesktop"
              spotify &
              waitForWindow "spotify"
              niri msg action focus-monitor DP-2
              for ws in 3 2 1; do
                niri msg action focus-workspace "$ws"
                niri msg action focus-column-first
              done
              niri msg action focus-monitor DP-1
            '')) ]
            [ "steam" "-silent" ]
          ];
        };

        # --- DMS bar configs (zeus-specific monitors) ---
        programs.dank-material-shell.session = {
          weatherLocation = "Arnstorf, 94424";
          weatherCoordinates = "48.5615685,12.8218254";
          perMonitorWallpaper = true;
          monitorWallpapers = {
            DP-1 = "${config.home.homeDirectory}/.dotfiles/nix/wallpapers/12-5/mocha-3840x1600.png";
            DP-2 = "${config.home.homeDirectory}/.dotfiles/nix/wallpapers/16-9/mocha-1920x1080.png";
          };
          monitorWallpaperFillModes = { DP-1 = "Fit"; DP-2 = "Fit"; };
        };

        programs.dank-material-shell.settings = {
          controlCenterWidgets = [
            { enabled = true; id = "volumeSlider"; width = 50; }
            { id = "inputVolumeSlider"; enabled = true; width = 50; }
            { enabled = true; id = "audioInput"; width = 50; }
            { enabled = true; id = "audioOutput"; width = 50; }
            { enabled = true; id = "bluetooth"; width = 50; }
            { enabled = true; id = "wifi"; width = 50; }
            { enabled = true; id = "nightMode"; width = 50; }
            { id = "doNotDisturb"; enabled = true; width = 50; }
          ];
          barConfigs = [
            {
              id = "primary"; name = "Primary Bar"; enabled = true; position = 0;
              screenPreferences = [ "DP-1" ];
              leftWidgets = [ "workspaceSwitcher" { id = "focusedWindow"; enabled = true; focusedWindowCompactMode = false; } ];
              centerWidgets = [ { id = "privacyIndicator"; enabled = true; } { id = "clock"; enabled = true; } { id = "weather"; enabled = true; } { id = "separator"; enabled = true; } { id = "dankPomodoroTimer"; enabled = true; } ];
              rightWidgets = [
                { id = "systemTray"; enabled = true; }
                { id = "claudeCodeUsage"; enabled = true; }
                { id = "cpuUsage"; enabled = true; minimumWidth = true; }
                { id = "memUsage"; enabled = true; minimumWidth = true; showInGb = false; }
                { id = "keyboard_layout_name"; enabled = true; keyboardLayoutNameCompactMode = false; }
                { id = "battery"; enabled = true; }
                { id = "controlCenterButton"; enabled = true; showNetworkIcon = true; showBluetoothIcon = true; showAudioIcon = true; showAudioPercent = true; showVpnIcon = false; showBrightnessIcon = false; showBrightnessPercent = false; showMicIcon = false; showMicPercent = false; showBatteryIcon = false; showPrinterIcon = false; }
                { id = "notificationButton"; enabled = true; }
                { id = "powerMenuButton"; enabled = true; }
              ];
              spacing = 10; innerPadding = 0; widgetPadding = 10;
            }
            {
              id = "secondary"; name = "Secondary Bar"; enabled = true; position = 0;
              screenPreferences = [ "DP-2" ];
              leftWidgets = [ { id = "workspaceSwitcher"; enabled = true; } { id = "focusedWindow"; enabled = true; focusedWindowCompactMode = false; } ];
              centerWidgets = [ { id = "privacyIndicator"; enabled = true; } { id = "clock"; enabled = true; } { id = "separator"; enabled = true; } { id = "dankPomodoroTimer"; enabled = true; } ];
              rightWidgets = [ { id = "keyboard_layout_name"; enabled = true; keyboardLayoutNameCompactMode = false; } ];
              spacing = 10; innerPadding = 0; widgetPadding = 10;
            }
          ];
        };

        # --- Security: 1Password + opnix secrets ---
        internal.security._1password = {
          enable = true;
          opnix = {
            enable = true;
            secrets = {
              protonBridge = mkSecret "protonBridge" "op://Nix/Proton Bridge/password";
              googleMail = mkSecret "googleMail" "op://Nix/Google Nix App/password";
              googleCalendarClientId = mkSecret "googleCalendarClientId" "op://Nix/vdirsyncer/username";
              googleCalendarClientSecret = mkSecret "googleCalendarClientSecret" "op://Nix/vdirsyncer/credential";
              googleDriveClientId = mkSecret "googleDriveClientId" "op://Nix/rclone-gdrive/username";
              googleDriveClientSecret = mkSecret "googleDriveClientSecret" "op://Nix/rclone-gdrive/credential";
              googleDriveToken = mkSecret "googleDriveToken" "op://Nix/rclone-gdrive/token";
              protonDriveUsername = mkSecret "protonDriveUsername" "op://Nix/rclone-pdrive/username";
              protonDrivePassword = mkSecret "protonDrivePassword" "op://Nix/rclone-pdrive/password";
              protonDriveTotpSecretKey = mkSecret "protonDriveTotpSecretKey" "op://Nix/rclone-pdrive/otp secret";
            };
          };
        };

        # --- VCS identity ---
        internal.development.vcs = {
          signing.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2G7J57J+2prp4UH/oWhIk6q+/rrvIhlsCypkK6Ak+d";
        };

        # --- Storage: rclone ---
        internal.apps.storage.rclone = {
          googleDrive = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/.drives/g";
            clientIdCommand = "cat ${secretPaths.googleDriveClientId or ""}";
            clientSecretCommand = "cat ${secretPaths.googleDriveClientSecret or ""}";
            tokenCommand = "cat ${secretPaths.googleDriveToken or ""}";
          };
          protonDrive = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/.drives/p";
            usernameCommand = "cat ${secretPaths.protonDriveUsername or ""}";
            passwordCommand = "cat ${secretPaths.protonDrivePassword or ""}";
            totpSecretCommand = "cat ${secretPaths.protonDriveTotpSecretKey or ""}";
          };
        };

        # --- Email accounts ---
        internal.accounts.email = {
          proton = {
            enable = true;
            address = "michael.baudler@proton.me";
            aliases = [ "michael.baudler@pm.me" "me@mrbandler.dev" "catch@mrbandler.dev" "hello@mrbandler.dev" "b7sch@proton.me" ];
            realName = "Michael Baudler";
            passwordCommand = "cat ${secretPaths.protonBridge or ""}";
          };
          google = {
            enable = true;
            address = "baudler.michael@gmail.com";
            realName = "Michael Baudler";
            passwordCommand = "cat ${secretPaths.googleMail or ""}";
          };
        };

        # --- Calendar ---
        internal.accounts.calendar.google = {
          enable = true;
          oauth2ClientIdCommand = [ "cat" (secretPaths.googleCalendarClientId or "") ];
          oauth2ClientSecretCommand = [ "cat" (secretPaths.googleCalendarClientSecret or "") ];
          collections = [
            [ "events" "baudler.michael@gmail.com" "baudler.michael@gmail.com" ]
            [ "holidays" "cln2spr5e9mm2rh3d1nmoqb4c5sk0pridtqn0bjm5phm2r35dpi62shectnmuprcckn66rrd@virtual" "cln2spr5e9mm2rh3d1nmoqb4c5sk0pridtqn0bjm5phm2r35dpi62shectnmuprcckn66rrd@virtual" ]
            [ "vromis-daily-chaos" "e8d331252df1768615b83c49b911f388ad38735864127520c73cf9f1a0a173c4@group.calendar.google.com" "e8d331252df1768615b83c49b911f388ad38735864127520c73cf9f1a0a173c4@group.calendar.google.com" ]
            [ "birthdays" "535cfd434efbde5bb03123e4b2052343d0058f097595c28e4f12a0fabf4e137e@group.calendar.google.com" "535cfd434efbde5bb03123e4b2052343d0058f097595c28e4f12a0fabf4e137e@group.calendar.google.com" ]
          ];
        };

        # --- Environment variables ---
        home.sessionVariables = {
          TERMINAL = "wezterm";
          LAUNCHER = "vicinae toggle";
          EDITOR = "hx";
          VISUAL = "zeditor";
          PAGER = "bat --style=plain";
          BROWSER = "zen-beta";
          FILEMANAGER = "nautilus";
          PASS = "1password --quick-access";
        };
        systemd.user.sessionVariables = config.home.sessionVariables;

        # --- Thunderbird integration with email accounts ---
        accounts.email.accounts.proton.thunderbird = { enable = true; profiles = [ "default" ]; };
        accounts.email.accounts.google.thunderbird = { enable = true; profiles = [ "default" ]; };

        # --- Default apps ---
        home.packages = with pkgs; [ claude-desktop loupe file-roller gnome-disk-utility ];
        xdg.mimeApps.defaultApplications = {
          "image/png" = "org.gnome.Loupe.desktop";
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/gif" = "org.gnome.Loupe.desktop";
          "image/webp" = "org.gnome.Loupe.desktop";
          "image/svg+xml" = "org.gnome.Loupe.desktop";
          "image/bmp" = "org.gnome.Loupe.desktop";
          "image/tiff" = "org.gnome.Loupe.desktop";
          "image/avif" = "org.gnome.Loupe.desktop";
          "image/jxl" = "org.gnome.Loupe.desktop";
        };
      };
  };

  # =========================================================================
  # User aspect
  # =========================================================================
  den.aspects.mrbandler = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
    ];
  };
}

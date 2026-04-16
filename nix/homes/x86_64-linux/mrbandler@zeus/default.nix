{
  config,
  ...
}:
let
  secretPaths = config.internal.security._1password.opnix.secretPaths;
  mkSecret = config.lib.opnix.mkSecret;
in

{
  imports = [
    ./desktop
  ];

  home.stateVersion = "25.11";
  home.username = "mrbandler";
  home.homeDirectory = "/home/mrbandler";

  internal = {
    theme = {
      enable = true;
      wallpaper = ../../../wallpapers/12-5/mocha-3840x1600.png;
      colorScheme = "catppuccin-mocha";
      polarity = "dark";
    };

    maintenance = {
      enable = true;
      autoUpdate.enable = true;
    };

    security._1password = {
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

    desktop = {
      core = {
        keybindings.enable = true;
        commands.scratchTerminal.command = "zellij attach --create scratch";
      };
      launchers.vicinae.enable = true;
      fileManagers.nautilus.enable = true;
    };

    apps = {
      web = {
        firefox.enable = true;
        zen.enable = true;
      };
      gaming.enable = true;
      storage.rclone = {
        googleDrive = {
          enable = true;
          mountPoint = "${config.home.homeDirectory}/.drives/g";
          clientIdCommand = "cat ${secretPaths.googleDriveClientId}";
          clientSecretCommand = "cat ${secretPaths.googleDriveClientSecret}";
          tokenCommand = "cat ${secretPaths.googleDriveToken}";
        };
        protonDrive = {
          enable = true;
          mountPoint = "${config.home.homeDirectory}/.drives/p";
          usernameCommand = "cat ${secretPaths.protonDriveUsername}";
          passwordCommand = "cat ${secretPaths.protonDrivePassword}";
          totpSecretCommand = "cat ${secretPaths.protonDriveTotpSecretKey}";
        };
      };
    };

    cli = {
      terminals.wezterm.enable = true;
      multiplexers.zellij.enable = true;
    };

    accounts = {
      email = {
        proton = {
          enable = true;
          address = "michael.baudler@proton.me";
          aliases = [
            "michael.baudler@pm.me"
            "me@mrbandler.dev"
            "catch@mrbandler.dev"
            "hello@mrbandler.dev"
            "b7sch@proton.me"
          ];
          realName = "Michael Baudler";
          passwordCommand = "cat ${secretPaths.protonBridge}";
        };

        google = {
          enable = true;
          address = "baudler.michael@gmail.com";
          realName = "Michael Baudler";
          passwordCommand = "cat ${secretPaths.googleMail}";
        };
      };

      calendar.google = {
        enable = true;
        oauth2ClientIdCommand = [
          "cat"
          secretPaths.googleCalendarClientId
        ];
        oauth2ClientSecretCommand = [
          "cat"
          secretPaths.googleCalendarClientSecret
        ];
        collections = [
          [
            "events"
            "baudler.michael@gmail.com"
            "baudler.michael@gmail.com"
          ]
          [
            "holidays"
            "cln2spr5e9mm2rh3d1nmoqb4c5sk0pridtqn0bjm5phm2r35dpi62shectnmuprcckn66rrd@virtual"
            "cln2spr5e9mm2rh3d1nmoqb4c5sk0pridtqn0bjm5phm2r35dpi62shectnmuprcckn66rrd@virtual"
          ]
          [
            "vromis-daily-chaos"
            "e8d331252df1768615b83c49b911f388ad38735864127520c73cf9f1a0a173c4@group.calendar.google.com"
            "e8d331252df1768615b83c49b911f388ad38735864127520c73cf9f1a0a173c4@group.calendar.google.com"
          ]
          [
            "birthdays"
            "535cfd434efbde5bb03123e4b2052343d0058f097595c28e4f12a0fabf4e137e@group.calendar.google.com"
            "535cfd434efbde5bb03123e4b2052343d0058f097595c28e4f12a0fabf4e137e@group.calendar.google.com"
          ]
        ];
      };
    };

    development = {
      vcs = {
        enable = true;
        signing.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2G7J57J+2prp4UH/oWhIk6q+/rrvIhlsCypkK6Ak+d";
      };

      editors = {
        vscode.enable = true;
        zed.enable = true;
        helix.enable = true;
        neovim.enable = true;
      };

      runtimes.nodejs.enable = true;
      agents.claude-code.enable = true;
      agents.pi.enable = true;
    };
  };
}

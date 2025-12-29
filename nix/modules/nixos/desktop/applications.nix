{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.applications;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.applications = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable baseline desktop applications.";
    };

    browsers = {
      firefox = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Firefox browser.";
      };

      chromium = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Chromium browser.";
      };
    };

    fileManager = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable file manager.";
      };

      package = mkOption {
        type = types.enum [
          "dolphin"
          "nautilus"
          "thunar"
          "nemo"
        ];
        default = "dolphin";
        description = "File manager to use.";
      };

      thumbnails = mkOption {
        type = types.bool;
        default = true;
        description = "Enable thumbnail generation.";
      };
    };

    terminal = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable terminal emulator.";
      };

      package = mkOption {
        type = types.enum [
          "alacritty"
          "kitty"
          "wezterm"
          "foot"
          "st"
        ];
        default = "wezterm";
        description = "Terminal emulator to use.";
      };
    };

    textEditor = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable basic text editor.";
      };

      package = mkOption {
        type = types.enum [
          "kate"
          "gedit"
          "mousepad"
        ];
        default = "kate";
        description = "Text editor to use.";
      };
    };

    archiver = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable archive manager.";
      };

      package = mkOption {
        type = types.enum [
          "ark"
          "file-roller"
        ];
        default = "ark";
        description = "Archive manager to use.";
      };
    };

    pdfViewer = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable PDF viewer.";
      };

      package = mkOption {
        type = types.enum [
          "okular"
          "evince"
          "zathura"
        ];
        default = "okular";
        description = "PDF viewer to use.";
      };
    };

    imageViewer = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable image viewer.";
      };

      package = mkOption {
        type = types.enum [
          "gwenview"
          "eog"
          "imv"
        ];
        default = "gwenview";
        description = "Image viewer to use.";
      };
    };

    mediaPlayer = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable media player.";
      };

      package = mkOption {
        type = types.enum [
          "vlc"
          "mpv"
        ];
        default = "mpv";
        description = "Media player to use.";
      };
    };

    launcher = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable application launcher.";
      };

      package = mkOption {
        type = types.enum [
          "vicinae"
          "rofi"
          "wofi"
          "fuzzel"
          "tofi"
        ];
        default = "vicinae";
        description = "Application launcher to use.";
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # Browsers
    programs.firefox.enable = mkIf cfg.browsers.firefox true;
    environment.systemPackages =
      with pkgs;
      [ ]
      ++ optional cfg.browsers.chromium chromium

      # File manager
      ++ optional (cfg.fileManager.enable && cfg.fileManager.package == "dolphin") kdePackages.dolphin
      ++ optional (cfg.fileManager.enable && cfg.fileManager.package == "nautilus") gnome.nautilus
      ++ optional (cfg.fileManager.enable && cfg.fileManager.package == "thunar") xfce.thunar
      ++ optional (cfg.fileManager.enable && cfg.fileManager.package == "nemo") cinnamon.nemo

      # Thumbnail generation
      ++ optionals (cfg.fileManager.enable && cfg.fileManager.thumbnails) [
        ffmpegthumbnailer
        kdePackages.kdegraphics-thumbnailers
        kdePackages.kimageformats
        kdePackages.kio-extras
      ]

      # Terminal
      ++ optional (cfg.terminal.enable && cfg.terminal.package == "konsole") kdePackages.konsole
      ++ optional (cfg.terminal.enable && cfg.terminal.package == "alacritty") alacritty
      ++ optional (cfg.terminal.enable && cfg.terminal.package == "kitty") kitty
      ++ optional (cfg.terminal.enable && cfg.terminal.package == "wezterm") wezterm
      ++ optional (cfg.terminal.enable && cfg.terminal.package == "foot") foot

      # Text editor
      ++ optional (cfg.textEditor.enable && cfg.textEditor.package == "kate") kdePackages.kate
      ++ optional (cfg.textEditor.enable && cfg.textEditor.package == "gedit") gnome.gedit
      ++ optional (cfg.textEditor.enable && cfg.textEditor.package == "mousepad") xfce.mousepad

      # Archiver
      ++ optional (cfg.archiver.enable && cfg.archiver.package == "ark") kdePackages.ark
      ++ optional (cfg.archiver.enable && cfg.archiver.package == "file-roller") gnome.file-roller

      # PDF viewer
      ++ optional (cfg.pdfViewer.enable && cfg.pdfViewer.package == "okular") kdePackages.okular
      ++ optional (cfg.pdfViewer.enable && cfg.pdfViewer.package == "evince") gnome.evince
      ++ optional (cfg.pdfViewer.enable && cfg.pdfViewer.package == "zathura") zathura

      # Image viewer
      ++ optional (cfg.imageViewer.enable && cfg.imageViewer.package == "gwenview") kdePackages.gwenview
      ++ optional (cfg.imageViewer.enable && cfg.imageViewer.package == "eog") gnome.eog
      ++ optional (cfg.imageViewer.enable && cfg.imageViewer.package == "imv") imv

      # Media player
      ++ optional (cfg.mediaPlayer.enable && cfg.mediaPlayer.package == "vlc") vlc
      ++ optional (cfg.mediaPlayer.enable && cfg.mediaPlayer.package == "mpv") mpv

      # Launcher
      ++ optional (cfg.launcher.enable && cfg.launcher.package == "vicinae") vicinae
      ++ optional (cfg.launcher.enable && cfg.launcher.package == "rofi") rofi
      ++ optional (cfg.launcher.enable && cfg.launcher.package == "wofi") wofi
      ++ optional (cfg.launcher.enable && cfg.launcher.package == "fuzzel") fuzzel;

    # Enable GVFS for network shares, trash support, etc.
    services.gvfs.enable = mkIf cfg.fileManager.enable true;

    # Enable thumbnail generation service
    services.tumbler.enable = mkIf (cfg.fileManager.enable && cfg.fileManager.thumbnails) true;
  };
}

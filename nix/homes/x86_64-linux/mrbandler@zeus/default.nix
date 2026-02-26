{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

{
  home.stateVersion = "25.11";
  home.username = "mrbandler";
  home.homeDirectory = "/home/mrbandler";

  internal = {
    browsers = {
      firefox.enable = true;
      zen.enable = true;
    };

    terminals.wezterm.enable = true;
    security._1password = {
      enable = true;
      opnix = {
        enable = true;
        secrets = {};
      };
    };

    desktop = {
      wpaperd = {
        enable = true;
        mode = "center";
        monitors = {
          "DP-1" = {
            path = ../../../wallpapers/12-5/mocha-3840x1600.png;
            mode = "center";
          };
          "DP-2" = {
            path = ../../../wallpapers/16-9/mocha-1920x1080.png;
            mode = "center";
          };
        };
      };

      niri = {
        enable = true;
        settings = {
          outputs = {
            "DP-1" = {
              mode = {
                width = 3840;
                height = 1600;
                refresh = 74.977;
              };
              position = {
                x = 0;
                y = 0;
              };
              variable-refresh-rate = true;
            };
            "DP-2" = {
              mode = {
                width = 1920;
                height = 1080;
                refresh = 60.000;
              };
              position = {
                x = (3840 - 1920) / 2;
                y = 1600;
              };
              variable-refresh-rate = true;
            };
          };
        };
      };
    };

    launchers = {
      vicinae.enable = true;
    };

    editors = {
      vscode.enable = true;
      zed.enable = true;
      helix.enable = true;
    };

    development = {
      nodejs = {
        enable = true;
        enableYarn = true;
        enablePnpm = true;
      };

      claude-code.enable = true;
    };

    theme = {
      enable = true;
      wallpaper = ../../../wallpapers/12-5/mocha-3840x1600.png;
      colorScheme = "catppuccin-macchiato";
      polarity = "dark";
    };
  };
}

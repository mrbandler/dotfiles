{
  pkgs,
  ...
}:

let
  waitForWindow = appId: ''
    timeout=17
    while ! niri msg windows | grep -q 'App ID: "${appId}"'; do
      sleep 0.3
      timeout=$((timeout - 1))
      if [ $timeout -le 0 ]; then break; fi
    done
  '';

  waitForTitle = title: ''
    timeout=17
    while ! niri msg windows | grep -q 'Title: "${title}'; do
      sleep 0.3
      timeout=$((timeout - 1))
      if [ $timeout -le 0 ]; then break; fi
    done
  '';

  startup = pkgs.writeShellScript "workspace-startup" ''
    # Workspace 1: Zen → Claude Desktop
    zen-beta --profile $HOME/.config/zen/mrbandler &
    ${waitForWindow "zen-beta"}
    claude-desktop &
    ${waitForTitle "Claude"}

    # Workspace 2: WhatsApp → Telegram → Vesktop
    # WhatsApp's title isn't set at window creation, so open-on-workspace misses it.
    # We wait for the title, then move it manually via IPC.
    whatsapp-electron &
    ${waitForTitle "WhatsApp"}
    WA_ID=$(niri msg windows | grep -B1 'Title: "WhatsApp' | head -1 | grep -oP '\d+')
    if [ -n "$WA_ID" ]; then
      niri msg action focus-window --id "$WA_ID"
      niri msg action move-column-to-workspace 2 --focus false
    fi
    Telegram &
    ${waitForWindow "org.telegram.desktop"}
    vesktop &
    ${waitForWindow "vesktop"}

    # Workspace 3: Spotify
    spotify &
    ${waitForWindow "spotify"}

    # Reset all workspaces to first column, ending on workspace 1
    niri msg action focus-monitor DP-2
    for ws in 3 2 1; do
      niri msg action focus-workspace "$ws"
      niri msg action focus-column-first
    done
    niri msg action focus-monitor DP-1
  '';
in
{
  imports = [
    ./niri.nix
    ./dms.nix
  ];

  internal.desktop.core = {
    init.spawn = [
      [ "${startup}" ]
    ];

    workspaces = [
      {
        name = "1";
        monitor = "DP-2";
      }
      {
        name = "2";
        monitor = "DP-2";
      }
      {
        name = "3";
        monitor = "DP-2";
      }
    ];

    windowRules = [
      {
        matches = [ { appId = "^zen"; } ];
        excludes = [ { title = "Zen Browser Private Browsing"; } ];
        properties = {
          open-on-workspace = "1";
          default-column-width = {
            proportion = 1.0;
          };
        };
      }
      {
        matches = [ { title = "^Claude$"; } ];
        properties = {
          open-on-workspace = "1";
          default-column-width = {
            proportion = 1.0;
          };
        };
      }
      {
        matches = [ { title = "^WhatsApp"; } ];
        properties = {
          open-on-workspace = "2";
          default-column-width = {
            proportion = 0.5;
          };
        };
      }
      {
        matches = [ { appId = "^org\\.telegram\\.desktop$"; } ];
        properties = {
          open-on-workspace = "2";
          default-column-width = {
            proportion = 0.5;
          };
        };
      }
      {
        matches = [ { appId = "^vesktop$"; } ];
        properties = {
          open-on-workspace = "2";
          default-column-width = {
            proportion = 1.0;
          };
        };
      }
      {
        matches = [ { appId = "^spotify$"; } ];
        properties = {
          open-on-workspace = "3";
          default-column-width = {
            proportion = 1.0;
          };
        };
      }
      {
        matches = [ { appId = "^zen"; title = "^Picture-in-Picture$"; } ];
        properties = {
          open-floating = true;
        };
      }
      {
        matches = [ { appId = "^org\\.quickshell$"; title = "^System Monitor$"; } ];
        properties = {
          open-floating = true;
          default-column-width = { proportion = 0.5; };
          default-window-height = { proportion = 0.75; };
        };
      }
    ];
  };
}

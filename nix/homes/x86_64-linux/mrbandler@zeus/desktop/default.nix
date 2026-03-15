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

  startup = pkgs.writeShellScript "workspace-startup" ''
    # Workspace 1: Zen → Claude Desktop → WezTerm
    zen-beta &
    ${waitForWindow "zen-beta"}
    claude-desktop &
    ${waitForWindow "Claude"}
    wezterm &
    ${waitForWindow "org.wezfurlong.wezterm"}

    # Workspace 2: WhatsApp → Telegram → Vesktop
    whatsapp-electron &
    ${waitForWindow "whatsapp-electron"}
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
        properties = {
          open-on-workspace = "1";
          default-column-width = {
            proportion = 1.0;
          };
        };
      }
      {
        matches = [
          {
            appId = "^org\\.wezfurlong\\.wezterm$";
            atStartup = true;
          }
        ];
        properties = {
          open-on-workspace = "1";
          default-column-width = {
            proportion = 1.0;
          };
        };
      }
      {
        matches = [ { appId = "^Claude$"; } ];
        properties = {
          open-on-workspace = "1";
          default-column-width = {
            proportion = 1.0;
          };
        };
      }
      {
        matches = [ { appId = "^whatsapp-electron$"; } ];
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
    ];
  };
}

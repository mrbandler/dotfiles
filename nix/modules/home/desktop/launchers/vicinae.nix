{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

with lib;
let
  rev = "2ce22330aa8cfeb43c8fc99448173a7e8cb9e9c9";
  mkRaycastExt = config.lib.vicinae.mkRayCastExtension;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "desktop" "launchers" "vicinae" ] [ "programs" "vicinae" ])
  ];

  config = {
    programs.vicinae = {
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };

      settings = {
        close_on_focus_loss = true;
        launcher_window.layer_shell.enabled = false;
        favicon_service = "duckduckgo";

        providers = {
          "@khasbilegt/1password" = {
            preferences = {
              cliPath = "/etc/profiles/per-user/mrbandler/bin/op";
              zshPath = "/etc/profiles/per-user/mrbandler/bin/zsh";
            };
          };

          "@samlinville/tailscale" = {
            preferences.tailscalePath = "/run/current-system/sw/bin/tailscale";
          };

          "@mattisssa/spotify-player" = {
            entrypoints = {
              like.enabled = true;
              dislike.enabled = true;
              addPlayingSongToPlaylist = {
                enabled = true;
                preferences.duplicateSongCheck = true;
              };
              volume.enabled = true;
              volumeUp.enabled = true;
              volumeDown.enabled = true;
            };
          };
        };
      };

      extensions =
        (with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
          # System
          bluetooth
          power-profile
          process-manager
          pulseaudio
          wifi-commander

          # Desktop
          niri

          # Dev
          github
          zed-recents
          nix
        ])
        ++ [
          # Raycast extensions
          (mkRaycastExt {
            name = "1password";
            inherit rev;
            sha256 = "sha256-94h3i5bMKDAtaCvkE7BM0bTFsx1YuzUDC9vg2mJ3Yq0=";
          })
          (mkRaycastExt {
            name = "linear";
            inherit rev;
            sha256 = "sha256-0HE+125/kt6dKCJo4T9rHRTQzjmvTHm5iqxCv/txyaQ=";
          })
          (mkRaycastExt {
            name = "spotify-player";
            inherit rev;
            sha256 = "sha256-J4EaKxrqVJgIta0gYl5rvhNfILUdMoQhDpA9f9gRxJc=";
          })
          (mkRaycastExt {
            name = "remove-paywall";
            inherit rev;
            sha256 = "sha256-5E844SP8q//gH2cvMoJlV9NfvSdPAU6TYL1t2tCV6yc=";
          })
          (mkRaycastExt {
            name = "youtube";
            inherit rev;
            sha256 = "sha256-4lNsliLA89BCa2BzZKGeifgR7wuNvKW2QUaP1OdOkws=";
          })
          (mkRaycastExt {
            name = "tailscale";
            inherit rev;
            sha256 = "sha256-1MW+747L1xPRsrqcEydXFyCWf3mKH2lVHT9uSE8ss4k=";
          })
          (mkRaycastExt {
            name = "obsidian";
            inherit rev;
            sha256 = "sha256-ryK/5sTBIJk9mIAYuAqdkGJhs7h3D4+bAj8+zKjLLMg=";
          })
          (mkRaycastExt {
            name = "devdocs";
            inherit rev;
            sha256 = "sha256-tqhHLIyWpFBHhkt7AiJSfkjIqJNO3+Fkntt7mlbLYbY=";
          })
          (mkRaycastExt {
            name = "uuid-generator";
            inherit rev;
            sha256 = "sha256-27KqqcVWFbQegoWLfpRlsaUGoWrektcs8uirGaMIU4k=";
          })
          (mkRaycastExt {
            name = "steam";
            inherit rev;
            sha256 = "sha256-EWp5g1/OoF4An6x9PMeAbyHzfQqRSZsXkLjGMXD5WzQ=";
          })
          (mkRaycastExt {
            name = "protondb";
            inherit rev;
            sha256 = "sha256-mjcGBDiFPj+K7jc7g8BKrChbE5oYQelDj01Ryvm1Ip8=";
          })
        ]
        ++ [
          # Custom extensions
          inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.praxis
        ];
    };
  };
}

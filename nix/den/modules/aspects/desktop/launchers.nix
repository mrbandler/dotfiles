{ den, inputs, ... }: {
  den.aspects.desktop-launchers = {
    homeManager = { pkgs, lib, config, ... }:
      let
        rev = "2ce22330aa8cfeb43c8fc99448173a7e8cb9e9c9";
        mkRaycastExt = config.lib.vicinae.mkRayCastExtension;
      in
      {
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
              "@samlinville/tailscale" = {
                preferences.tailscalePath = "${pkgs.tailscale}/bin/tailscale";
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
              bluetooth power-profile process-manager
              pulseaudio wifi-commander niri nix
            ])
            ++ [
              (mkRaycastExt { name = "linear"; inherit rev; sha256 = "sha256-0HE+125/kt6dKCJo4T9rHRTQzjmvTHm5iqxCv/txyaQ="; })
              (mkRaycastExt { name = "spotify-player"; inherit rev; sha256 = "sha256-J4EaKxrqVJgIta0gYl5rvhNfILUdMoQhDpA9f9gRxJc="; })
              (mkRaycastExt { name = "tailscale"; inherit rev; sha256 = "sha256-1MW+747L1xPRsrqcEydXFyCWf3mKH2lVHT9uSE8ss4k="; })
              (mkRaycastExt { name = "uuid-generator"; inherit rev; sha256 = "sha256-27KqqcVWFbQegoWLfpRlsaUGoWrektcs8uirGaMIU4k="; })
            ]
            ++ [
              inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.praxis
            ];
        };
      };
  };
}

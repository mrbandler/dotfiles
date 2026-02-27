{ lib,
  config,
  pkgs,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "browsers" "zen" ] [ "programs" "zen-browser" ])
  ];

  config = {
    # Workaround for custom profiles issue: https://github.com/0xc000022070/zen-browser-flake/issues/179
    home.sessionVariables.MOZ_LEGACY_PROFILES = "1";
    stylix.targets.zen-browser.profileNames = [ config.home.username ];

    programs.zen-browser = {
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };

      profiles.${config.home.username} =
        let
          containers = {};
          spaces = {};
          pins = {};
        in
      {
        id = 0;
        name = config.home.username;
        isDefault = true;

        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          onepassword-password-manager
          darkreader
        ];

        search = {
          force = true;
          default = "duckduckgo";
        };

        settings = {
          extensions = {
            autoDisableScopes = 0;
            allowPrivateBrowsingByDefault = true;
          };
        };
      }
      // lib.optionalAttrs (containers != {}) {
        containersForce = true;
        inherit containers;
      }
      // lib.optionalAttrs (spaces != {}) {
        spacesForce = true;
        inherit spaces;
      }
      // lib.optionalAttrs (pins != {}) {
        pinsForce = true;
        inherit pins;
      };
    };
  };
}

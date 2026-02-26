{
  lib,
  config,
  input
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "browsers" "zen" ] [ "programs" "zen-browser" ])
  ];

  config = {
    programs.zen-browser {
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
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; {
        ublock-origin
        onepassword-password-manager
      };
      profiles..${config.home.username} = {
        search = {
          force = true;
          default = "ddg";
        };
      };
    };
  };
}

{
  lib,
  config,
  ...
}:

with lib;
let
  protonEnabled = config.internal.accounts.email.proton.enable;
  googleEnabled = config.internal.accounts.email.google.enable;
  profileName = config.home.username;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "comms" "thunderbird" ] [ "programs" "thunderbird" ])
  ];

  config = {
    programs.thunderbird = {
      enable = true;
      profiles.${profileName} = {
        isDefault = true;
      };
    };

    # Enable Thunderbird on configured email accounts
    accounts.email.accounts = mkMerge [
      (mkIf protonEnabled {
        proton.thunderbird = {
          enable = true;
          profiles = [ profileName ];
        };
      })
      (mkIf googleEnabled {
        google.thunderbird = {
          enable = true;
          profiles = [ profileName ];
        };
      })
    ];
  };
}

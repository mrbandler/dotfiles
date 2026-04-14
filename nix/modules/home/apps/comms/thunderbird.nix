{
  lib,
  config,
  ...
}:

with lib;
let
  protonEnabled = config.internal.accounts.email.proton.enable;
  googleEnabled = config.internal.accounts.email.google.enable;
  googleCalendarEnabled = config.internal.accounts.calendar.google.enable;
  googleCalendarCollections = config.internal.accounts.calendar.google.collections;
  profileName = config.home.username;

  mkCalDavUrl = calendarId:
    "https://apidata.googleusercontent.com/caldav/v2/${calendarId}/events/";
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

    # Google Calendars via CalDAV for Thunderbird
    # Each collection is [local-name, calendar-id, local-id]
    accounts.calendar.accounts = mkIf (googleCalendarEnabled && googleEnabled) (
      builtins.listToAttrs (map (col:
        let
          name = builtins.elemAt col 0;
          calendarId = builtins.elemAt col 1;
        in
        {
          name = "thunderbird-${name}";
          value = {
            primary = false;
            primaryCollection = calendarId;
            remote = {
              type = "caldav";
              url = mkCalDavUrl calendarId;
            };
            thunderbird = {
              enable = true;
              profiles = [ profileName ];
            };
          };
        }
      ) googleCalendarCollections)
    );
  };
}

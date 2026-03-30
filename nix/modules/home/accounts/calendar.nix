{
  lib,
  config,
  ...
}:

with lib;
let
  khalEnabled = config.programs.khal.enable or false;
  vdirsyncerEnabled = config.programs.vdirsyncer.enable or false;
  cfg = config.internal.accounts.calendar.google;
in
{
  options.internal.accounts.calendar.google = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Google Calendar sync";
    };

    oauth2ClientIdCommand = mkOption {
      type = with types; listOf str;
      default = [];
      description = "Command to retrieve Google OAuth2 client ID";
      example = [ "cat" "/path/to/secret" ];
    };

    oauth2ClientSecretCommand = mkOption {
      type = with types; listOf str;
      default = [];
      description = "Command to retrieve Google OAuth2 client secret";
      example = [ "cat" "/path/to/secret" ];
    };

    collections = mkOption {
      type = with types; listOf (listOf str);
      default = [];
      description = "Calendar collections to sync. Each entry is [local-name remote-id local-id]. If empty, syncs all calendars.";
      example = [
        ["events" "user@gmail.com" "user@gmail.com"]
      ];
    };
  };

  config = mkIf cfg.enable {
    accounts.calendar.basePath = ".local/share/calendars";

    accounts.calendar.accounts.google = {
      primary = true;
      primaryCollection = config.internal.accounts.email.google.address;

      remote = {
        type = "google_calendar";
      };

      khal = mkIf khalEnabled {
        enable = true;
        type = "discover";
      };

      vdirsyncer = mkIf vdirsyncerEnabled {
        enable = true;
        collections =
          if cfg.collections != []
          then cfg.collections
          else [ "from a" ];
        tokenFile = "${config.xdg.dataHome}/vdirsyncer/google-calendar-token";
        clientIdCommand = cfg.oauth2ClientIdCommand;
        clientSecretCommand = cfg.oauth2ClientSecretCommand;
      };
    };
  };
}

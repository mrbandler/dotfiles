{ den, ... }: {
  den.aspects.accounts-calendar = {
    homeManager = { lib, config, ... }:
      with lib;
      let
        khalEnabled = config.programs.khal.enable or false;
        vdirsyncerEnabled = config.programs.vdirsyncer.enable or false;
        cfg = config.internal.accounts.calendar.google;
      in
      {
        options.internal.accounts.calendar.google = {
          enable = mkOption { type = types.bool; default = false; };
          oauth2ClientIdCommand = mkOption { type = types.listOf types.str; default = []; };
          oauth2ClientSecretCommand = mkOption { type = types.listOf types.str; default = []; };
          collections = mkOption { type = types.listOf (types.listOf types.str); default = []; };
        };

        config = mkIf cfg.enable {
          accounts.calendar.basePath = ".local/share/calendars";
          accounts.calendar.accounts.google = {
            primary = true;
            primaryCollection = config.internal.accounts.email.google.address;
            remote.type = "google_calendar";
            khal = mkIf khalEnabled { enable = true; type = "discover"; };
            vdirsyncer = mkIf vdirsyncerEnabled {
              enable = true;
              collections = if cfg.collections != [] then cfg.collections else [ "from a" ];
              tokenFile = "${config.xdg.dataHome}/vdirsyncer/google-calendar-token";
              clientIdCommand = cfg.oauth2ClientIdCommand;
              clientSecretCommand = cfg.oauth2ClientSecretCommand;
            };
          };
        };
      };
  };
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.locale = {
    timeZone = mkOption {
      type = types.str;
      default = "Europe/Berlin";
      description = "System timezone.";
    };

    defaultLocale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "Default system locale.";
    };

    extraLocales = mkOption {
      type = types.listOf types.str;
      default = [ "de_DE.UTF-8/UTF-8" ];
      description = "Additional locales to generate.";
    };

    extraLocaleSettings = mkOption {
      type = types.attrs;
      default = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };
      description = "Extra locale settings.";
    };
  };

  config = mkIf cfg.enable {
    time.timeZone = cfg.locale.timeZone;
    i18n = {
      defaultLocale = cfg.locale.defaultLocale;
      extraLocales = cfg.locale.extraLocales;
      extraLocaleSettings = cfg.locale.extraLocaleSettings;
    };
  };
}

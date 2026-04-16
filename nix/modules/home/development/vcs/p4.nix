{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.development.vcs.p4;
in
{
  options.internal.development.vcs.p4 = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Perforce (p4) CLI";
    };

    visual = mkOption {
      type = types.bool;
      default = true;
      description = "Enable p4v (Perforce Visual Client)";
    };

    port = mkOption {
      type = types.str;
      default = "perforce:1666";
      description = "Default P4PORT (Perforce server address)";
    };

    user = mkOption {
      type = types.str;
      default = config.home.username;
      description = "Default P4USER (Perforce username)";
    };

    client = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default P4CLIENT (Perforce workspace). Per-project, leave null to set manually.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.p4 ]
      ++ optional cfg.visual pkgs.p4v;

    xdg.desktopEntries = mkIf cfg.visual {
      p4v = {
        name = "P4V";
        genericName = "Perforce Visual Client";
        exec = "p4v";
        icon = "p4v";
        terminal = false;
        categories = [ "Development" "RevisionControl" ];
      };
      p4admin = {
        name = "P4Admin";
        genericName = "Perforce Administration Tool";
        exec = "p4admin";
        icon = "p4admin";
        terminal = false;
        categories = [ "Development" "RevisionControl" ];
      };
    };

    home.sessionVariables = mkMerge [
      { P4PORT = cfg.port; }
      { P4USER = cfg.user; }
      (mkIf (cfg.client != null) { P4CLIENT = cfg.client; })
    ];
  };
}

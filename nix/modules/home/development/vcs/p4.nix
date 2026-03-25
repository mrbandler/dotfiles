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

    home.sessionVariables = mkMerge [
      { P4PORT = cfg.port; }
      { P4USER = cfg.user; }
      (mkIf (cfg.client != null) { P4CLIENT = cfg.client; })
    ];
  };
}

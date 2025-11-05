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
  options.${namespace}.core.nix = {
    settings = {
      additionalTrustedUsers = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional trusted users.";
      };
    };

    gc = {
      automatic = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic garbage collection.";
      };
      dates = mkOption {
        type = with types; either singleLineStr (listOf str);
        default = "weekly";
        description = "When to run garbage collection.";
      };
      options = mkOption {
        type = types.singleLineStr;
        default = "--delete-older-than 7d";
        description = "Options passed to nix-collect-garbage.";
      };
    };
  };

  config = mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = mkDefault true;
        max-jobs = mkDefault "auto";
        cores = mkDefault 0;
        trusted-users = [
          "root"
          "@wheel"
        ]
        ++ cfg.nix.settings.additionalTrustedUsers;
      };

      gc = {
        automatic = cfg.nix.gc.automatic;
        dates = cfg.nix.gc.dates;
        options = cfg.nix.gc.options;
      };
    };
  };
}

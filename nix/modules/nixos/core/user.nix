{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.user = {
    name = mkOption {
      type = types.str;
      default = "mrbandler";
      description = "Primary user name.";
    };

    description = mkOption {
      type = types.str;
      default = "mrbandler";
      description = "User description.";
    };

    additionalGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional groups for the user.";
    };
  };

  config = mkIf cfg.enable {
    users = {
      defaultUserShell = mkDefault pkgs.bash;
      users.${cfg.user.name} = {
        isNormalUser = true;
        description = cfg.user.description;
        extraGroups = [
          "wheel"
          "networkmanager"
        ]
        ++ cfg.user.additionalGroups;
      };
    };
  };
}

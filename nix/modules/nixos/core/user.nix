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

    icon = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Profile image for the user (used by AccountsService).";
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
          "input"
        ]
        ++ cfg.user.additionalGroups;
      };
    };

    system.activationScripts.userIcon = mkIf (cfg.user.icon != null) {
      text = ''
        mkdir -p /var/lib/AccountsService/icons
        cp ${cfg.user.icon} /var/lib/AccountsService/icons/${cfg.user.name}

        mkdir -p /var/lib/AccountsService/users
        cat > /var/lib/AccountsService/users/${cfg.user.name} <<EOF
        [User]
        Icon=/var/lib/AccountsService/icons/${cfg.user.name}
        EOF
      '';
    };
  };
}

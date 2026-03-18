{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.security._1password;
in
{
  options.${namespace}.security._1password = {
    enable = mkEnableOption "1Password";

    enableCli = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 1Password CLI with SGID wrapper.";
    };

    enableGui = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 1Password GUI with polkit policies.";
    };

    polkitPolicyOwners = mkOption {
      type = types.listOf types.str;
      default = [ config.${namespace}.core.user.name ];
      description = "Users allowed to authorize 1Password actions via polkit.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enableCli {
      programs._1password.enable = true;
    })

    (mkIf cfg.enableGui {
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = cfg.polkitPolicyOwners;
      };
    })
  ]);
}

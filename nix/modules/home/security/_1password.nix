{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.security._1password;
in
{
  imports = [
    (mkAliasOptionModule
      [ "internal" "security" "_1password" "opnix" ]
      [ "programs" "onepassword-secrets" ])
  ];

  options.internal.security._1password = {
    enable = mkEnableOption "1Password";

    enableCli = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 1Password CLI";
    };

    enableGui = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 1Password GUI";
    };

    enableSshAgent = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 1Password SSH agent";
    };

    enableGitSigning = mkOption {
      type = types.bool;
      default = false;
      description = "Enable 1Password Git commit signing";
    };

    shellPlugins = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable 1Password shell plugins";
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "The 1Password CLI package to use for shell plugins. When null, defaults to pkgs._1password-cli";
      };

      plugins = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [ gh ];
        description = "CLI packages to enable 1Password shell plugins for";
        example = literalExpression "with pkgs; [ gh awscli2 google-cloud-sdk cachix ]";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs;
        (optional cfg.enableCli _1password-cli)
        ++ (optional cfg.enableGui _1password-gui);
    }

    (mkIf cfg.shellPlugins.enable {
      programs._1password-shell-plugins = {
        enable = true;
        package = cfg.shellPlugins.package;
        plugins = cfg.shellPlugins.plugins;
      };
    })

    (mkIf cfg.enableSshAgent {
      programs.ssh = {
        enable = true;
        extraConfig = ''
          Host *
            IdentityAgent ~/.1password/agent.sock
        '';
      };
    })

    (mkIf cfg.enableGitSigning {
      programs.git = {
        extraConfig = {
          gpg.format = "ssh";
          gpg.ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
          commit.gpgsign = true;
        };
      };
    })
  ]);
}

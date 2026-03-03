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

    sshAgent = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable 1Password SSH agent";
      };

      vaults = mkOption {
        type = types.listOf types.str;
        default = [ "Development" ];
        description = "List of vaults to expose SSH keys from (in order of preference)";
        example = [ "Development" "Private" "Keys" ];
      };
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

    (mkIf cfg.sshAgent.enable {
      programs.ssh = {
        enable = true;
        matchBlocks."*" = {
          identityAgent = "~/.1password/agent.sock";
          extraOptions = {
            IPQoS = "none";
          };
        };
      };

      home.file.".config/1Password/ssh/agent.toml".text = ''
        # Managed by Home Manager
        ${concatMapStringsSep "\n" (vault: ''
        [[ssh-keys]]
        vault = "${vault}"
        '') cfg.sshAgent.vaults}
      '';
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

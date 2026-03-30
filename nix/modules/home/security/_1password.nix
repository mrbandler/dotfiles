{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.security._1password;
  injectsWithTargets = filterAttrs (_: s: s.injectInto != []) cfg.injects;
in
{
  imports = [
    (mkAliasOptionModule
      [ "internal" "security" "_1password" "opnix" ]
      [ "programs" "onepassword-secrets" ]
    )
  ];

  options.internal.security._1password = {
    enable = mkEnableOption "1Password";

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
        example = [
          "Development"
          "Private"
          "Keys"
        ];
      };
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

    injects = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
            readOnly = true;
            description = "Auto-populated from attribute name.";
          };

          reference = mkOption {
            type = types.str;
            default = "";
            description = "1Password op:// URI for this secret.";
          };

          injectInto = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Config file paths relative to $HOME where this secret's placeholder should be substituted.";
          };
        };
      }));
      default = {};
      description = "1Password secrets with optional injection into config files.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      lib.opnix = {
        injectSecret = secret: "@opnix:${secret.name}@";
        mkSecret = name: reference: {
          inherit reference;
          path = ".config/opnix/secrets/${name}";
        };
      };
    }

    (mkIf cfg.shellPlugins.enable {
      programs._1password-shell-plugins = {
        enable = true;
        package = cfg.shellPlugins.package;
        plugins = cfg.shellPlugins.plugins;
      };
    })

    (mkIf cfg.sshAgent.enable {
      internal.desktop.core.init.spawn = [
        [
          "1password"
          "--silent"
        ]
      ];

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
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

    (mkIf cfg.opnix.enable {
      home.file.".config/opnix/.keep".text = "";
      programs.onepassword-secrets.tokenFile = "${config.home.homeDirectory}/.config/opnix/token";
    })

    {
      assertions = [
        {
          assertion = osConfig.programs._1password.enable or false;
          message = "1Password requires system-level support for SGID wrappers. Set `internal.security._1password.enable = true` in your NixOS system config.";
        }
      ] ++ mapAttrsToList (name: secret: {
        assertion = secret.injectInto != [] -> secret.reference != "";
        message = "1Password secret '${name}' has injectInto targets but no reference defined.";
      }) cfg.injects;
    }

    {
      programs.onepassword-secrets.secrets = mapAttrs (_: secret: {
        inherit (secret) reference;
      }) (filterAttrs (_: s: s.reference != "") cfg.injects);
    }

    (mkIf (injectsWithTargets != {}) {
      home.activation.injectOpnixSecrets = lib.hm.dag.entryAfter [ "retrieveOpnixSecrets" ] ''
        ${concatStringsSep "\n" (mapAttrsToList (name: secret:
          let
            secretFile = config.programs.onepassword-secrets.secretPaths.${name};
            tag = "@opnix:${name}@";
          in
          concatMapStringsSep "\n" (targetRelPath:
            let
              targetPath = "${config.home.homeDirectory}/${targetRelPath}";
            in
            ''
              if [ ! -f "${secretFile}" ]; then
                echo "Warning: secret file '${secretFile}' not found, skipping injection for '${name}'"
              elif [ ! -e "${targetPath}" ]; then
                echo "Warning: target file '${targetPath}' not found, skipping injection for '${name}'"
              else
                if [ -L "${targetPath}" ]; then
                  _target=$(readlink -f "${targetPath}")
                  rm "${targetPath}"
                  cp "$_target" "${targetPath}"
                fi
                _secret=$(cat "${secretFile}")
                ${pkgs.gnused}/bin/sed -i "s|${tag}|$_secret|g" "${targetPath}"
              fi
            ''
          ) secret.injectInto
        ) injectsWithTargets)}
      '';
    })
  ]);
}

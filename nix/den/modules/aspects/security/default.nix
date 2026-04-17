{ den, inputs, ... }: {
  den.aspects.security = {
    nixos = { pkgs, lib, config, ... }: {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "mrbandler" ];
      };
    };

    homeManager = { pkgs, lib, config, ... }:
      with lib;
      let
        injectsWithTargets = filterAttrs (_: s: s.injectInto != []) config.internal.security._1password.injects;

        getExeName = package:
          strings.unsafeDiscardStringContext (baseNameOf (lib.getExe package));
        nushellPluginCommands = concatMapStringsSep "\n" (package:
          let exe = getExeName package; in ''
            def --wrapped ${exe} [...args] {
              op plugin run -- ${exe} ...$args
            }
          ''
        ) config.internal.security._1password.shellPlugins.plugins;
      in
      {
        imports = [
          inputs._1password-shell-plugins.hmModules.default
          inputs.opnix.homeManagerModules.default
          (mkAliasOptionModule
            [ "internal" "security" "_1password" "opnix" ]
            [ "programs" "onepassword-secrets" ]
          )
        ];

        # Keep the options for injects/sshAgent/shellPlugins — hosts populate these
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
              description = "Vaults to expose SSH keys from";
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
              description = "1Password CLI package for shell plugins";
            };
            plugins = mkOption {
              type = types.listOf types.package;
              default = with pkgs; [ gh hcloud ];
              description = "CLI packages to enable 1Password shell plugins for";
            };
          };

          injects = mkOption {
            type = types.attrsOf (types.submodule ({ name, ... }: {
              options = {
                name = mkOption {
                  type = types.str;
                  default = name;
                  readOnly = true;
                };
                reference = mkOption {
                  type = types.str;
                  default = "";
                  description = "1Password op:// URI for this secret";
                };
                injectInto = mkOption {
                  type = types.listOf types.str;
                  default = [];
                  description = "Config file paths relative to $HOME for placeholder substitution";
                };
              };
            }));
            default = {};
          };
        };

        config = mkIf config.internal.security._1password.enable (
          let cfg = config.internal.security._1password; in
          mkMerge [
            {
              lib.opnix = {
                injectSecret = secret: "@opnix:${secret.name}@";
                mkSecret = name: reference: {
                  inherit reference;
                  path = ".local/share/opnix/secrets/${name}";
                };
              };

              programs.onepassword-secrets.secrets = mapAttrs (_: secret: {
                inherit (secret) reference;
              }) (filterAttrs (_: s: s.reference != "") cfg.injects);
            }

            (mkIf cfg.shellPlugins.enable {
              programs._1password-shell-plugins = {
                enable = true;
                package = cfg.shellPlugins.package;
                plugins = cfg.shellPlugins.plugins;
              };
              programs.nushell.extraConfig = mkIf config.programs.nushell.enable nushellPluginCommands;
            })

            (mkIf cfg.sshAgent.enable {
              programs.ssh = {
                enable = true;
                enableDefaultConfig = false;
                matchBlocks."*" = {
                  identityAgent = "~/.1password/agent.sock";
                  extraOptions.IPQoS = "none";
                };
              };

              home.file.".config/1Password/ssh/agent.toml".text = ''
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
          ]
        );
      };
  };
}

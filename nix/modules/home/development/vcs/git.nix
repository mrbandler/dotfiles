{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  vcsCfg = config.internal.development.vcs;
  cfg = vcsCfg.git;

  # Generate includeIf configs for each context
  contextIncludes = mapAttrsToList (path: identity: {
    condition = "gitdir:${path}/";
    contents = {
      user = {
        name = identity.name;
        email = identity.email;
      };
    };
  }) vcsCfg.identity.contexts;
in
{
  options.internal.development.vcs.git = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Git configuration";
    };

    delta = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable delta for git diffs";
      };

      theme = mkOption {
        type = types.str;
        default = "Catppuccin Macchiato";
        description = "Syntax theme for delta";
      };
    };
  };

  config = mkIf (vcsCfg.enable && cfg.enable) {
    programs.git = {
      enable = true;

      userName = vcsCfg.identity.default.name;
      userEmail = vcsCfg.identity.default.email;

      signing = mkIf vcsCfg.signing.enable {
        key = vcsCfg.signing.publicKey;
        signByDefault = true;
      };

      extraConfig = mkMerge [
        (mkIf vcsCfg.signing.enable {
          gpg.format = "ssh";
          gpg.ssh.program = vcsCfg.signing.program;
        })
        {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
        }
      ];

      delta = mkIf cfg.delta.enable {
        enable = true;
        options = {
          navigate = true;
          syntax-theme = cfg.delta.theme;
          line-numbers = true;
          side-by-side = false;
        };
      };

      includes = contextIncludes;
    };
  };
}

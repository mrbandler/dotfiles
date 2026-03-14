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
    # Ensure ~/.gitconfig points to the XDG config managed by home-manager
    # This prevents legacy gitconfig files from overriding our declarative config
    home.file.".gitconfig".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/git/config";

    programs.git = {
      enable = true;

      signing = mkIf vcsCfg.signing.enable {
        key = vcsCfg.signing.publicKey;
        signByDefault = true;
      };

      settings = mkMerge [
        {
          user = {
            name = vcsCfg.identity.default.name;
            email = vcsCfg.identity.default.email;
          };
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
        }
        (mkIf vcsCfg.signing.enable {
          gpg.format = "ssh";
          gpg.ssh.program = vcsCfg.signing.program;
        })
      ];

      includes = contextIncludes;
    };

    programs.delta = mkIf cfg.delta.enable {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        syntax-theme = cfg.delta.theme;
        line-numbers = true;
        side-by-side = false;
      };
    };
  };
}

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

};

  config = mkIf (vcsCfg.enable && cfg.enable) {
    # Ensure ~/.gitconfig points to the XDG config managed by home-manager
    # This prevents legacy gitconfig files from overriding our declarative config
    home.file.".gitconfig".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/git/config";

    programs.git = {
      enable = true;

      ignores = [
        # OS
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"
        "._*"
        ".Spotlight-V100"
        ".Trashes"
        ".AppleDB"
        ".AppleDesktop"
        "Thumbs.db"
        "Thumbs.db:encryptable"
        "ehthumbs.db"
        "ehthumbs_vista.db"
        "[Dd]esktop.ini"
        "$RECYCLE.BIN/"
        "*.lnk"
        "*~"
        ".fuse_hidden*"
        ".directory"
        ".Trash-*"
        ".nfs*"

        # Editors
        "*.swp"
        "*.swo"
        "*~"
        "[._]*.s[a-v][a-z]"
        "!*.svg"
        "[._]*.sw[a-p]"
        "[._]s[a-rt-v][a-z]"
        "[._]ss[a-gi-z]"
        "[._]*.un~"
        "Session.vim"
        "Sessionx.vim"
        ".netrwhist"
        "tags"
        ".idea/"
        ".vscode/*"
        "!.vscode/settings.json"
        "!.vscode/tasks.json"
        "!.vscode/launch.json"
        "!.vscode/extensions.json"
        "!.vscode/*.code-snippets"
        "*.code-workspace"

        # Direnv
        ".direnv"
        ".envrc"

        # Environment
        ".env"
        ".env.local"
        ".env.development.local"
        ".env.test.local"
        ".env.production.local"
      ];

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
};
}

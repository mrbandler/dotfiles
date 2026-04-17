{ den, ... }: {
  den.aspects.development = {
    homeManager = { pkgs, lib, config, ... }:
      with lib;
      let
        devDir = lib.mkDefault "~/dev";
        vcsCfg = config.internal.development.vcs;
        identityModule = types.submodule {
          options = {
            name = mkOption { type = types.str; };
            email = mkOption { type = types.str; };
          };
        };
        contextIncludes = mapAttrsToList (path: identity: {
          condition = "gitdir:${path}/";
          contents.user = { name = identity.name; email = identity.email; };
        }) vcsCfg.identity.contexts;

        jjConfig = lib.concatStringsSep "\n" ([
          "[user]"
          ''name = "${vcsCfg.identity.default.name}"''
          ''email = "${vcsCfg.identity.default.email}"''
        ] ++ optionals vcsCfg.signing.enable [
          "[signing]"
          "sign-all = true"
          ''backend = "ssh"''
          ''key = "${vcsCfg.signing.publicKey}"''
          "[signing.backends.ssh]"
          ''program = "${vcsCfg.signing.program}"''
        ] ++ [
          "[ui]"
          ''diff.tool = ["delta", "--paging=never"]''
          ''pager = "delta"''
        ] ++ concatMap (path:
          let id = vcsCfg.identity.contexts.${path}; in [
            "[[--scope]]"
            ''--when.repositories = ["${path}"]''
            ''user.name = "${id.name}"''
            ''user.email = "${id.email}"''
          ]
        ) (attrNames vcsCfg.identity.contexts));
      in
      {
        options.internal.development = {
          devDir = mkOption { type = types.str; default = "~/dev"; };

          vcs = {
            enable = mkOption { type = types.bool; default = true; };
            identity = {
              default = {
                name = mkOption { type = types.str; default = "mrbandler"; };
                email = mkOption { type = types.str; default = "me@mrbandler.dev"; };
              };
              contexts = mkOption {
                type = types.attrsOf identityModule;
                default = {
                  "${config.internal.development.devDir}/mrbandler" = { name = "mrbandler"; email = "me@mrbandler.dev"; };
                  "${config.internal.development.devDir}/ffg" = { name = "Michael Baudler"; email = "michael.baudler@fivefingergames.com"; };
                  "${config.internal.development.devDir}/ss" = { name = "Michael Baudler"; email = "michael.baudler@smokingsquid.games"; };
                  "${config.internal.development.devDir}/la" = { name = "mrbandler"; email = "mrbandler@leakyabstractions.dev"; };
                };
              };
            };
            signing = {
              enable = mkOption { type = types.bool; default = true; };
              publicKey = mkOption { type = types.nullOr types.str; default = null; };
              program = mkOption { type = types.str; default = "${pkgs._1password-gui}/bin/op-ssh-sign"; };
            };
            git.enable = mkOption { type = types.bool; default = true; };
          };
        };

        config = mkIf vcsCfg.enable {
          assertions = [{
            assertion = !vcsCfg.signing.enable || vcsCfg.signing.publicKey != null;
            message = "VCS signing.publicKey must be set when signing is enabled";
          }];

          home.file.".gitconfig".source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/.config/git/config";

          programs.git = {
            enable = true;
            ignores = [
              ".DS_Store" ".AppleDouble" ".LSOverride" "._*" ".Spotlight-V100" ".Trashes"
              ".AppleDB" ".AppleDesktop" "Thumbs.db" "Thumbs.db:encryptable" "ehthumbs.db"
              "ehthumbs_vista.db" "[Dd]esktop.ini" "$RECYCLE.BIN/" "*.lnk" "*~"
              ".fuse_hidden*" ".directory" ".Trash-*" ".nfs*"
              "*.swp" "*.swo" "*~" "[._]*.s[a-v][a-z]" "!*.svg" "[._]*.sw[a-p]"
              "[._]s[a-rt-v][a-z]" "[._]ss[a-gi-z]" "[._]*.un~" "Session.vim" "Sessionx.vim"
              ".netrwhist" "tags" ".idea/" ".vscode/*" "!.vscode/settings.json"
              "!.vscode/tasks.json" "!.vscode/launch.json" "!.vscode/extensions.json"
              "!.vscode/*.code-snippets" "*.code-workspace"
              ".direnv" ".envrc"
              ".env" ".env.local" ".env.development.local" ".env.test.local" ".env.production.local"
            ];
            signing = mkIf vcsCfg.signing.enable {
              key = vcsCfg.signing.publicKey;
              signByDefault = true;
            };
            settings = mkMerge [
              {
                user = { name = vcsCfg.identity.default.name; email = vcsCfg.identity.default.email; };
                init.defaultBranch = "main";
                pull.rebase = true;
                push.autoSetupRemote = true;
              }
              (mkIf vcsCfg.signing.enable { gpg.format = "ssh"; gpg.ssh.program = vcsCfg.signing.program; })
            ];
            includes = contextIncludes;
          };

          programs.gh = { enable = true; settings.git_protocol = "ssh"; };

          home.packages = with pkgs; [ jujutsu p4 ];
          home.file.".jjconfig.toml".text = jjConfig;

          # Dev tools
          programs.delta = { enable = true; enableGitIntegration = true; options = { navigate = true; line-numbers = true; side-by-side = true; }; };
          home.packages = with pkgs; [ git-cliff gh-enhance diffnav gh-dash nodejs_22 ];
          home.sessionVariables.NODE_PATH = lib.mkDefault "${pkgs.nodejs_22}/lib/node_modules";

          xdg.configFile."diffnav/config.yml".source = ./diffnav-config.yml;
          xdg.configFile."gh-dash/config.yml".source = ./gh-dash-config.yml;
        };
      };
  };
}

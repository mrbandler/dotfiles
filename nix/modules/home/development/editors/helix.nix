{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "editors" "helix" ] [ "programs" "helix" ])
  ];

  config = {
    programs.helix = {
      enable = true;
      defaultEditor = false; # Managed by internal.env.editor

      settings = {
        editor = {
          line-number = "relative";
          auto-format = true;
          auto-pairs = true;
          rulers = [ 80 100 120 ];
          soft-wrap.enable = true;
          indent-guides.render = true;
          gutters = [ "diagnostics" "line-numbers" "spacer" "diff" ];
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          statusline = {
            left = [ "mode" "spinner" "file-name" "file-modification-indicator" ];
            right = [ "diagnostics" "selections" "register" "position" "file-encoding" "file-line-ending" "file-type" ];
          };
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
          file-picker = {
            hidden = false;
            git-ignore = true;
          };
        };

        keys.normal.space = {
          e = ":sh zellij run -c -f --x 10% --y 10% --width 80% --height 80% -- yazi";
          g = ":sh zellij run -c --floating -- lazygit";
          t = ":sh zellij run -d down -- nu";
        };
      };

      languages = {
        language-server.nushell-lsp = {
          command = "nu";
          args = [ "--lsp" ];
        };

        language = [
          {
            name = "nix";
            formatter.command = "nixfmt";
            auto-format = true;
          }
          {
            name = "toml";
            formatter.command = "taplo";
            formatter.args = [ "fmt" "-" ];
            auto-format = true;
          }
          {
            name = "javascript";
            formatter.command = "prettierd";
            formatter.args = [ ".js" ];
            auto-format = true;
          }
          {
            name = "typescript";
            formatter.command = "prettierd";
            formatter.args = [ ".ts" ];
            auto-format = true;
          }
          {
            name = "jsx";
            formatter.command = "prettierd";
            formatter.args = [ ".jsx" ];
            auto-format = true;
          }
          {
            name = "tsx";
            formatter.command = "prettierd";
            formatter.args = [ ".tsx" ];
            auto-format = true;
          }
          {
            name = "html";
            formatter.command = "prettierd";
            formatter.args = [ ".html" ];
            auto-format = true;
          }
          {
            name = "css";
            formatter.command = "prettierd";
            formatter.args = [ ".css" ];
            auto-format = true;
          }
          {
            name = "json";
            formatter.command = "prettierd";
            formatter.args = [ ".json" ];
            auto-format = true;
          }
          {
            name = "yaml";
            formatter.command = "prettierd";
            formatter.args = [ ".yaml" ];
            auto-format = true;
          }
          {
            name = "markdown";
            formatter.command = "prettierd";
            formatter.args = [ ".md" ];
            auto-format = true;
          }
          {
            name = "nu";
            language-servers = [ "nushell-lsp" ];
          }
        ];
      };
    };
  };
}

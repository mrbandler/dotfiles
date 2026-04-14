{
  lib,
  config,
  ...
}:

with lib;
let
  statuslineScript = ./statusline.sh;
in
{
  imports = [
    (mkAliasOptionModule
      [ "internal" "development" "agents" "claude-code" ]
      [ "programs" "claude-code" ]
    )
  ];

  config.programs.claude-code = {
    mcpServers = {
      nixos = {
        command = "nix";
        args = [
          "run"
          "github:utensils/mcp-nixos"
          "--"
        ];
      };
    };
    settings = {
      includeCoAuthoredBy = false;
      attribution = {
        commit = "";
        pr = "";
      };
      statusLine = {
        type = "command";
        command = "bash ${statuslineScript}";
      };
      extraKnownMarketplaces = {
        superpowers-marketplace = {
          source = {
            source = "github";
            repo = "obra/superpowers-marketplace";
          };
        };
        neoeinstein-plugins = {
          source = {
            source = "github";
            repo = "neoeinstein/claude-plugins";
          };
        };
      };
      enabledPlugins = {
        # Core
        "superpowers@superpowers-marketplace" = true;
        "context7@claude-plugins-official" = true;
        "github@claude-plugins-official" = true;
        "remember@claude-plugins-official" = true;
        "security-guidance@claude-plugins-official" = true;
        "commit-commands@claude-plugins-official" = true;
        "linear@claude-plugins-official" = true;
        "feature-dev@claude-plugins-official" = true;

        # LSP
        "typescript-lsp@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
        "gopls-lsp@claude-plugins-official" = true;
        "csharp-lsp@claude-plugins-official" = true;
        "clangd-lsp@claude-plugins-official" = true;
        "lua-lsp@claude-plugins-official" = true;

        # Rust
        "rust-best-practices@neoeinstein-plugins" = true;

        # Tools
        "code-simplifier@claude-plugins-official" = true;
        "skill-creator@claude-plugins-official" = true;
        "hookify@claude-plugins-official" = true;
        "plugin-dev@claude-plugins-official" = true;
        "semgrep@claude-plugins-official" = true;
        "chrome-devtools-mcp@claude-plugins-official" = true;

        # Output styles
        "explanatory-output-style@claude-plugins-official" = true;
        "learning-output-style@claude-plugins-official" = true;
      };
    };
  };
}

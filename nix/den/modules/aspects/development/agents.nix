{ den, ... }: {
  den.aspects.development-agents = {
    homeManager = { pkgs, lib, config, ... }:
      let
        jsonFormat = pkgs.formats.json {};
        statuslineScript = ./claude-code-statusline.sh;
      in
      {
        programs.claude-code = {
          mcpServers.nixos = {
            command = "nix";
            args = [ "run" "github:utensils/mcp-nixos" "--" ];
          };
          settings = {
            includeCoAuthoredBy = false;
            attribution = { commit = ""; pr = ""; };
            statusLine = { type = "command"; command = "bash ${statuslineScript}"; };
            extraKnownMarketplaces = {
              superpowers-marketplace = { source = { source = "github"; repo = "obra/superpowers-marketplace"; }; };
              neoeinstein-plugins = { source = { source = "github"; repo = "neoeinstein/claude-plugins"; }; };
            };
            enabledPlugins = {
              "superpowers@superpowers-marketplace" = true;
              "context7@claude-plugins-official" = true;
              "github@claude-plugins-official" = true;
              "remember@claude-plugins-official" = true;
              "security-guidance@claude-plugins-official" = true;
              "commit-commands@claude-plugins-official" = true;
              "linear@claude-plugins-official" = true;
              "feature-dev@claude-plugins-official" = true;
              "typescript-lsp@claude-plugins-official" = true;
              "rust-analyzer-lsp@claude-plugins-official" = true;
              "gopls-lsp@claude-plugins-official" = true;
              "csharp-lsp@claude-plugins-official" = true;
              "clangd-lsp@claude-plugins-official" = true;
              "lua-lsp@claude-plugins-official" = true;
              "rust-best-practices@neoeinstein-plugins" = true;
              "code-simplifier@claude-plugins-official" = true;
              "skill-creator@claude-plugins-official" = true;
              "hookify@claude-plugins-official" = true;
              "plugin-dev@claude-plugins-official" = true;
              "semgrep@claude-plugins-official" = true;
              "chrome-devtools-mcp@claude-plugins-official" = true;
              "explanatory-output-style@claude-plugins-official" = true;
              "learning-output-style@claude-plugins-official" = true;
            };
          };
        };

        home.packages = [ pkgs.pi-coding-agent ];
      };
  };
}

{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # Language servers
    nil                                # Nix
    bash-language-server               # Bash
    taplo                              # TOML
    yaml-language-server               # YAML
    vscode-langservers-extracted       # HTML, CSS, JSON
    marksman                           # Markdown
    lemminx                            # XML
    dockerfile-language-server         # Dockerfiles
    docker-compose-language-service    # Docker Compose

    # Formatters
    nixfmt                             # Nix
    prettierd                          # Web (HTML, CSS, JS, JSON, YAML, MD)
  ];
}

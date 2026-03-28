{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.posting;
  yamlFormat = pkgs.formats.yaml {};
  batEnabled = config.programs.bat.enable or false;

  catppuccinThemesSrc = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "posting";
    rev = "main";
    hash = "sha256-xfoyqZ2Jz5of5PxJe6A0icobZNEyMcxBOsES51vPnZs=";
  };

  catppuccinThemes = pkgs.runCommand "catppuccin-posting-themes" {} ''
    mkdir -p $out
    for f in ${catppuccinThemesSrc}/themes/*/*.yaml; do
      cp "$f" "$out/"
    done
  '';
in
{
  options.internal.cli.tools.posting = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable posting HTTP TUI client";
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = {};
      description = "Posting configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.posting ];

    internal.cli.tools.posting.settings = mkMerge [
      (mapAttrsRecursive (_: mkDefault) {
        theme = "catppuccin-mocha-blue";
        layout = "vertical";
        animation = "full";
        spacing = "standard";
        response = {
          prettify_json = true;
          show_size_and_time = true;
        };
        heading = {
          visible = true;
          show_host = true;
          show_version = true;
        };
        url_bar = {
          show_value_preview = true;
          hide_secrets_in_value_preview = true;
        };
        collection_browser = {
          position = "left";
          show_on_startup = true;
        };
        focus = {
          on_startup = "url";
          on_response = "body";
          on_request_open = "url";
        };
        text_input = {
          blinking_cursor = true;
        };
        command_palette = {
          theme_preview = false;
        };
      })
      (mkIf batEnabled (mapAttrsRecursive (_: mkDefault) {
        pager_json = "bat --language=json --style=plain --paging=always";
      }))
    ];

    xdg.dataFile."posting/themes" = {
      source = catppuccinThemes;
      recursive = true;
    };

    xdg.configFile."posting/config.yaml".source =
      yamlFormat.generate "posting-config.yaml" cfg.settings;
  };
}

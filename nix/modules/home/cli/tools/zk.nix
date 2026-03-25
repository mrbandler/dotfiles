{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.zk;
  tomlFormat = pkgs.formats.toml {};
  batEnabled = config.programs.bat.enable or false;
  fzfEnabled = config.programs.fzf.enable or false;
in
{
  options.internal.cli.tools.zk = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zk Zettelkasten note-taking assistant";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = {};
      description = "Zk configuration as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.zk ];

    internal.cli.tools.zk.settings = mkMerge [
      (mapAttrsRecursive (_: mkDefault) {
        note = {
          filename = "{{id}}-{{slug title}}";
          extension = "md";
          template = "";
          id-charset = "alphanum";
          id-length = 4;
          id-case = "lower";
        };
        editor.command = "hx";
        format.markdown = {
          link-format = "markdown";
          hashtags = true;
        };
        lsp.diagnostics = {
          wiki-title = "hint";
          dead-link = "error";
        };
      })
      (mkIf batEnabled (mapAttrsRecursive (_: mkDefault) {
        tool.pager = "bat --style=plain";
      }))
      (mkIf fzfEnabled (mapAttrsRecursive (_: mkDefault) {
        tool.fzf-preview = "bat --color=always --style=plain {-1}";
      }))
    ];

    xdg.configFile."zk/config.toml".source =
      tomlFormat.generate "zk-config.toml" cfg.settings;
  };
}

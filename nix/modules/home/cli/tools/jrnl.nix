{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.jrnl;
  yamlFormat = pkgs.formats.yaml {};
  configFile = yamlFormat.generate "jrnl.yaml" cfg.settings;
in
{
  options.internal.cli.tools.jrnl = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable jrnl command line journal";
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = {};
      description = "Jrnl configuration as attribute set";
    };

    templates = mkOption {
      type = types.attrsOf types.lines;
      default = {};
      description = "Template files written to jrnl config directory, keyed by filename";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.jrnl ];

    internal.cli.tools.jrnl.settings = mapAttrsRecursive (_: mkDefault) {
      default_hour = 9;
      default_minute = 0;
      editor = "hx";
      encrypt = false;
      highlight = true;
      indent = 2;
      linewrap = 120;
      tagsymbols = "@";
      template = false;
      timeformat = "%F %H:%M";
      journals = {
        default = {
          journal = "~/.local/share/jrnl/journal.txt";
        };
      };
    };

    # Copy config as mutable file — jrnl writes to its config at runtime
    home.activation.jrnlConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      install -Dm644 ${configFile} $HOME/.config/jrnl/jrnl.yaml
    '';

    xdg.configFile = mapAttrs'
      (name: value: nameValuePair "jrnl/templates/${name}" { text = value; })
      cfg.templates;
  };
}

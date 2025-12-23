{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.env = {
    editor = mkOption {
      type = types.str;
      default = "hx";
      description = "Default text editor (EDITOR environment variable).";
    };

    pager = mkOption {
      type = types.str;
      default = "less";
      description = "Default pager (PAGER environment variable).";
    };
  };

  config = mkIf cfg.enable {
    environment.variables = {
      EDITOR = cfg.env.editor;
      PAGER = cfg.env.pager;
    };
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.development.agents.pi;
  jsonFormat = pkgs.formats.json {};
in
{
  options.internal.development.agents.pi = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Pi coding agent";
    };

    settings = mkOption {
      type = jsonFormat.type;
      default = {};
      description = "Pi global settings as attribute set";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.pi-coding-agent ];

    home.file.".pi/agent/settings.json" = mkIf (cfg.settings != {}) {
      source = jsonFormat.generate "pi-settings.json" cfg.settings;
    };
  };
}

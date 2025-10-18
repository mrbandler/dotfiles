{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.example;
in
{
  options.internal.example = {
    enable = mkEnableOption "example module";

    someOption = mkOption {
      type = types.str;
      default = "default-value";
      description = "Example option";
    };
  };

  config = mkIf cfg.enable {
    environment.variables.EXAMPLE_VAR = cfg.someOption;
  };
}

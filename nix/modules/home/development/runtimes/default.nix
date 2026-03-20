{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.development.runtimes;
in
{
  options.internal.development.runtimes = {
    nodejs = {
      enable = mkEnableOption "Node.js";

      package = mkOption {
        type = types.package;
        default = pkgs.nodejs_22;
        description = "Node.js package to use.";
      };
    };

    python = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Python runtime.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.python3;
        description = "Python package to use.";
      };
    };

    bun.enable = mkEnableOption "Bun";
    ruby.enable = mkEnableOption "Ruby";
    lua.enable = mkEnableOption "Lua";
  };

  config = {
    home.packages =
      optional cfg.nodejs.enable cfg.nodejs.package
      ++ optional cfg.python.enable cfg.python.package
      ++ optional cfg.bun.enable pkgs.bun
      ++ optional cfg.ruby.enable pkgs.ruby
      ++ optional cfg.lua.enable pkgs.lua;

    home.sessionVariables = mkIf cfg.nodejs.enable {
      NODE_PATH = "${cfg.nodejs.package}/lib/node_modules";
    };
  };
}

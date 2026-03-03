{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.development.nodejs;
in
{
  options.internal.development.nodejs = {
    enable = mkEnableOption "Node.js development environment";

    package = mkOption {
      type = types.package;
      default = pkgs.nodejs_22;
      description = "Node.js package to use.";
      example = literalExpression "pkgs.nodejs_20";
    };

    enableYarn = mkOption {
      type = types.bool;
      default = true;
      description = "Install Yarn package manager.";
    };

    enablePnpm = mkOption {
      type = types.bool;
      default = true;
      description = "Install pnpm package manager.";
    };

    npmPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Global npm packages to install via Nix.";
      example = literalExpression ''
        with pkgs.nodePackages; [
          typescript
          typescript-language-server
          prettier
        ]
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        cfg.package
      ]
      ++ optional cfg.enableYarn yarn
      ++ optional cfg.enablePnpm pnpm
      ++ cfg.npmPackages;

    home.sessionVariables = {
      # Ensure node binaries are available
      NODE_PATH = "${cfg.package}/lib/node_modules";
    };
  };
}

{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.documentation = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system documentation.";
    };

    nixos = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NixOS manual (nixos-help command).";
      };
    };

    man = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable man pages for installed packages.";
      };
    };

    dev = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable development documentation (headers, API docs). Saves ~100-500MB when disabled.";
      };
    };

    info = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable info pages.";
      };
    };

    doc = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable package documentation (/share/doc).";
      };
    };
  };

  config = mkIf cfg.enable {
    documentation = {
      enable = cfg.documentation.enable;
      nixos.enable = cfg.documentation.nixos.enable;
      man.enable = cfg.documentation.man.enable;
      dev.enable = cfg.documentation.dev.enable;
      info.enable = cfg.documentation.info.enable;
      doc.enable = cfg.documentation.doc.enable;
    };
  };
}

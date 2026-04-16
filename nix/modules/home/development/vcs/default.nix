{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.development.vcs;
  devDir = config.internal.development.devDir;

  identityModule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Git user name for this context";
      };
      email = mkOption {
        type = types.str;
        description = "Git email for this context";
      };
    };
  };
in
{
  imports = [
    ./git.nix
    ./gh.nix
    ./jj.nix
    ./p4.nix
  ];

  options.internal.development.vcs = {
    enable = mkEnableOption "VCS tools (Git, Jujutsu)";

    identity = {
      default = {
        name = mkOption {
          type = types.str;
          default = "mrbandler";
          description = "Default git user name";
        };
        email = mkOption {
          type = types.str;
          default = "me@mrbandler.dev";
          description = "Default git email";
        };
      };

      contexts = mkOption {
        type = types.attrsOf identityModule;
        default = {
          "${devDir}/mrbandler" = {
            name = "mrbandler";
            email = "me@mrbandler.dev";
          };
          "${devDir}/ffg" = {
            name = "Michael Baudler";
            email = "michael.baudler@fivefingergames.com";
          };
          "${devDir}/ss" = {
            name = "Michael Baudler";
            email = "michael.baudler@smokingsquid.games";
          };
          "${devDir}/la" = {
            name = "mrbandler";
            email = "mrbandler@leakyabstractions.dev";
          };
        };
        description = "Directory-based identity overrides";
      };
    };

    signing = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable commit signing";
      };

      publicKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "SSH public key for commit signing (required if signing.enable is true)";
      };

      program = mkOption {
        type = types.str;
        default = "${pkgs._1password-gui}/bin/op-ssh-sign";
        description = "Program to use for SSH signing";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.signing.enable || cfg.signing.publicKey != null;
        message = "internal.development.vcs.signing.publicKey must be set when signing is enabled";
      }
    ];
  };
}

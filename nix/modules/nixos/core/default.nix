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
  options.${namespace}.core = {
    enable = mkEnableOption "enable core";

    boot = {
      refind = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable rEFInd boot manager";
        };
      };

      plymouth = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Plymouth boot splash";
        };

        theme = mkOption {
          type = types.str;
          default = "catppuccin-mocha";
          description = "Plymouth theme to use";
        };

        themePackages = mkOption {
          type = types.listOf types.package;
          default = with pkgs; [
            (catppuccin-plymouth.override { variant = "mocha"; })
          ];
          description = "Additional Plymouth theme packages to install.";
        };
      };
    };

    networking = {
      hostName = mkOption {
        type = types.str;
        default = "nixos";
        description = "Hostname of the system.";
      };

      nameservers = mkOption {
        type = types.listOf types.str;
        default = [
          "1.0.0.1"
          "1.1.1.1"
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        # grub.enable = false;
        # systemd-boot.enable = false;
        # refind.enable = cfg.boot.refind.enable;
      };

      # plymouth = {
      #   enable = cfg.boot.plymouth.enable;
      #   theme = cfg.boot.plymouth.theme;
      #   themePackages = cfg.boot.plymouth.themePackages;
      # };
    };

    networking = {
      hostName = cfg.networking.hostName;
      nameservers = cfg.networking.nameservers;
      networkmanager = {
        enable = true;
        dns = "none";
        insertNameservers = cfg.networking.nameservers;
      };
    };
  };
}

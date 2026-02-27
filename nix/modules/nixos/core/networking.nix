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
  options.${namespace}.core.networking = {
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
        "8.8.8.8"
        "8.8.4.4"
      ];
      description = "List of DNS nameservers to use with NetworkManager.";
    };

    firewall = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable firewall.";
      };
      allowedTCPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "TCP ports to allow through firewall.";
      };
      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "UDP ports to allow through firewall.";
      };
    };

    wifi = {
      powersave = mkOption {
        type = types.bool;
        default = false;
        description = "Enable WiFi power saving.";
      };
    };

    tailscale = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Tailscale.";
      };
      port = mkOption {
        type = types.int;
        default = 0;
        description = "Custom Tailscale port to use.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.tailscale =  {
      enable = cfg.networking.tailscale.enable;
      port = cfg.networking.tailscale.port;
    };
    networking = {
      hostName = cfg.networking.hostName;
      nameservers = cfg.networking.nameservers;
      useDHCP = mkDefault false;
      dhcpcd.enable = mkDefault false;

      firewall = {
        enable = cfg.networking.firewall.enable;
        allowedTCPPorts = cfg.networking.firewall.allowedTCPPorts;
        allowedUDPPorts = cfg.networking.firewall.allowedUDPPorts;
      };

      networkmanager = {
        enable = mkDefault true;
        dns = mkDefault "none";
        insertNameservers = cfg.networking.nameservers;
        wifi.powersave = cfg.networking.wifi.powersave;

        settings.connection = {
          "ipv6.addr-gen-mode" = mkDefault "stable-privacy";
          "ipv6.ip6-privacy" = mkDefault "2"; # Prefer temporary addresses
        };
      };
    };
  };
}

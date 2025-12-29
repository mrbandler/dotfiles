{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop;
in
{
  imports = [
    ./sddm.nix
    ./greetd.nix
    ./gpu.nix
    ./niri.nix
    ./plasma.nix
    ./audio.nix
    ./bluetooth.nix
    ./printing.nix
    ./portals.nix
    ./input.nix
    ./media.nix
    ./applications.nix
    ./virtualization.nix
    ./gaming.nix
  ];

  options.${namespace}.desktop = {
    enable = mkEnableOption "enable desktop";

    defaultSession = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default desktop session.";
      example = "plasma";
    };
  };

  config = mkIf cfg.enable {
    security.polkit.enable = true;

    services.displayManager = {
      defaultSession = mkIf (cfg.defaultSession != null) cfg.defaultSession;
    };

    environment.systemPackages = with pkgs; [
      xdg-utils
      xdg-user-dirs
      wayland
      xwayland
      wayland-utils
      wayland-protocols
      wl-clipboard
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    }
    // optionalAttrs cfg.gpu.nvidia.enable {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}

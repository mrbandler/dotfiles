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
  options.${namespace}.desktop = {
    enable = mkEnableOption "desktop environment configuration";
  };

  config = mkIf cfg.enable {
    security.polkit.enable = true;

    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660"
    '';

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
    };
  };
}

{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:

with lib;
let
  cfg = config.internal.apps.gaming;
  gamingEnabled = osConfig.internal.desktop.services.gaming.enable or false;
in
{
  imports = [
    ./steam.nix
    ./mangohud.nix
    ./lutris.nix
  ];

  options.internal.apps.gaming = {
    enable = mkEnableOption "gaming applications";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = gamingEnabled;
        message = "Gaming apps require system-level gaming support. Set `internal.desktop.services.gaming.enable = true` in your NixOS system config.";
      }
    ];

    home.packages = with pkgs; [
      heroic
      itch
    ];
  };
}

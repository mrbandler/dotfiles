{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "comms" "vesktop" ] [ "programs" "vesktop" ])
  ];

  config.programs.vesktop = {
    enable = true;
    settings = {
      discordBranch = "stable";
      minimizeToTray = true;
      arRPC = true;
      checkUpdates = false;
      customTitleBar = false;
      splashTheming = true;
      hardwareAcceleration = true;
    };
  };
}

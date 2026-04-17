{ den, ... }: {
  den.aspects.apps-comms = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        telegram-desktop
        whatsapp-electron
      ];

      programs.vesktop = {
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

      programs.thunderbird = {
        enable = true;
        profiles.default = { isDefault = true; };
      };
    };
  };
}

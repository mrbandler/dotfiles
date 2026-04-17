{ den, ... }: {
  den.aspects.gaming-steam = {
    nixos = { pkgs, lib, ... }: {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = lib.mkDefault false;
        dedicatedServer.openFirewall = lib.mkDefault false;
        gamescopeSession.enable = lib.mkDefault false;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
          };
        };
      };
    };
  };
}

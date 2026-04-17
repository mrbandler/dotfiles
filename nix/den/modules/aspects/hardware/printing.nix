{ den, ... }: {
  den.aspects.hardware-printing = {
    nixos = { pkgs, ... }: {
      services.printing.enable = true;

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      hardware.sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
      };

      users.groups.scanner = {};
      users.users.mrbandler.extraGroups = [ "scanner" "lp" ];
    };
  };
}

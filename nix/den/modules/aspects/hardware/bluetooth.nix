{ den, ... }: {
  den.aspects.hardware-bluetooth = {
    nixos = { ... }: {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };

      systemd.services.bluetooth.wantedBy = [ "multi-user.target" ];
      services.blueman.enable = true;
    };
  };
}

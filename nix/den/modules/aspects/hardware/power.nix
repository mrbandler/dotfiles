{ den, ... }: {
  den.aspects.hardware-power = {
    nixos = { pkgs, lib, ... }: {
      services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "never";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };

      services.power-profiles-daemon.enable = lib.mkForce false;

      powerManagement.enable = true;

      boot.kernelModules = [ "acpi_call" ];

      environment.systemPackages = with pkgs; [
        powertop
        acpi
      ];
    };
  };
}

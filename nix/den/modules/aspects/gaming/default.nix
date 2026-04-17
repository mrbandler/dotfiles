{ den, ... }: {
  den.aspects.gaming = {
    includes = [ den.aspects.gaming-steam ];

    nixos = { pkgs, lib, ... }: {
      hardware.graphics.enable32Bit = true;

      boot.kernel.sysctl = {
        "vm.max_map_count" = 2147483642;
      };

      boot.kernelModules = [ "ntsync" ];

      programs.gamemode = {
        enable = true;
        settings = lib.mkDefault {};
      };
    };

    homeManager = { pkgs, lib, ... }: {
      programs.mangohud = {
        enable = true;
        settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
          fps_limit = 0;
          gpu_stats = true;
          gpu_temp = true;
          gpu_power = true;
          cpu_stats = true;
          cpu_temp = true;
          ram = true;
          vram = true;
          fps = true;
          frametime = true;
          frame_timing = true;
          font_size = 20;
          position = "top-left";
          toggle_hud = "Pause";
          no_display = true;
        };
      };

      programs.lutris.enable = true;

      home.packages = with pkgs; [
        heroic
        itch
        rpcs3
        pcsx2
        ppsspp
        retroarch
        xemu
      ];
    };
  };
}

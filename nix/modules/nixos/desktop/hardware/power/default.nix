{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.hardware.power;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.hardware.power = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable power management for laptops and mobile devices.
        Not needed for desktop PCs with constant power supply.
      '';
    };

    backend = mkOption {
      type = types.enum [
        "tlp"
        "auto-cpufreq"
      ];
      default = "auto-cpufreq";
      description = ''
        Power management backend to use.
        - tlp: Mature, stable, good defaults (traditional choice)
        - auto-cpufreq: Modern replacement for TLP with GUI support (v2.0+)

        WARNING: These backends conflict! Only one can be enabled at a time.
        auto-cpufreq is the community trend in 2025.
      '';
    };

    tlp = {
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Additional TLP configuration.";
        example = ''
          START_CHARGE_THRESH_BAT0=75
          STOP_CHARGE_THRESH_BAT0=80
        '';
      };
    };

    autoCpufreq = {
      settings = mkOption {
        type = types.attrs;
        default = {
          battery = {
            governor = "powersave";
            scaling_min_freq = 1400000;
            scaling_max_freq = 1800000;
            turbo = "never";
          };
          charger = {
            governor = "performance";
            scaling_min_freq = 1400000;
            scaling_max_freq = 3500000;
            turbo = "auto";
          };
        };
        description = ''
          auto-cpufreq configuration settings.
          Adjust frequencies based on your CPU specifications.
        '';
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    assertions = [
      {
        assertion = cfg.backend == "tlp" || cfg.backend == "auto-cpufreq";
        message = "Power management backend must be either 'tlp' or 'auto-cpufreq'";
      }
    ];

    # TLP power management
    services.tlp = mkIf (cfg.backend == "tlp") {
      enable = true;
      settings = {
        # Battery charge thresholds (extend battery life)
        START_CHARGE_THRESH_BAT0 = mkDefault 75;
        STOP_CHARGE_THRESH_BAT0 = mkDefault 80;

        # CPU scaling
        CPU_SCALING_GOVERNOR_ON_AC = mkDefault "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = mkDefault "powersave";

        # CPU boost
        CPU_BOOST_ON_AC = mkDefault 1;
        CPU_BOOST_ON_BAT = mkDefault 0;

        # CPU min/max frequencies (adjust based on your CPU)
        CPU_SCALING_MIN_FREQ_ON_AC = mkDefault 1400000;
        CPU_SCALING_MAX_FREQ_ON_AC = mkDefault 3500000;
        CPU_SCALING_MIN_FREQ_ON_BAT = mkDefault 1400000;
        CPU_SCALING_MAX_FREQ_ON_BAT = mkDefault 1800000;

        # WiFi power saving
        WIFI_PWR_ON_AC = mkDefault "off";
        WIFI_PWR_ON_BAT = mkDefault "on";

        # Runtime power management for PCI(e) devices
        RUNTIME_PM_ON_AC = mkDefault "on";
        RUNTIME_PM_ON_BAT = mkDefault "auto";

        # Disk settings
        DISK_IDLE_SECS_ON_AC = mkDefault 0;
        DISK_IDLE_SECS_ON_BAT = mkDefault 2;

        # SATA aggressive link power management
        SATA_LINKPWR_ON_AC = mkDefault "med_power_with_dipm";
        SATA_LINKPWR_ON_BAT = mkDefault "min_power";
      };

      # Allow user-provided extra configuration
      extraConfig = mkIf (cfg.tlp.extraConfig != "") cfg.tlp.extraConfig;
    };

    # auto-cpufreq power management
    services.auto-cpufreq = mkIf (cfg.backend == "auto-cpufreq") {
      enable = true;
      settings = cfg.autoCpufreq.settings;
    };

    # Disable power-profiles-daemon (conflicts with both TLP and auto-cpufreq)
    services.power-profiles-daemon.enable = mkForce false;

    # Additional power management optimizations
    powerManagement = {
      enable = true;

      # CPU frequency scaling
      cpuFreqGovernor = mkIf (cfg.backend == "tlp") (mkDefault "ondemand");

      # Powertop auto-tune (optional, can be enabled manually)
      powertop.enable = mkDefault false;
    };

    # Laptop mode for better battery life
    boot.kernelModules = [ "acpi_call" ]; # Needed for battery charge thresholds

    # Additional packages for power monitoring
    environment.systemPackages =
      with pkgs;
      [
        powertop # Power consumption analyzer
        acpi # Show battery status
      ]
      ++ optionals (cfg.backend == "auto-cpufreq") [
        # auto-cpufreq v2.0+ includes GUI
      ];
  };
}

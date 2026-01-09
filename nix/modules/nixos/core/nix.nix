{
  lib,
  config,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.core;
in
{
  options.${namespace}.core.nix = {
    settings = {
      additionalTrustedUsers = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional trusted users.";
      };

      additionalSubstituters = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional binary cache substituters.";
      };
    };

    gc = {
      automatic = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic garbage collection.";
      };
      dates = mkOption {
        type = with types; either singleLineStr (listOf str);
        default = "weekly";
        description = "When to run garbage collection.";
      };
      options = mkOption {
        type = types.singleLineStr;
        default = "--delete-older-than 30d";
        description = ''
          Options passed to nix-collect-garbage.
          Community default is 30 days to maintain more rollback options.
          7 days is more aggressive, good for space-constrained systems.
        '';
      };
    };

    autoUpgrade = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable automatic system upgrades.
          Disabled by default for desktop systems - manual updates give more control.
          Consider enabling for servers or systems you want to stay current automatically.
        '';
      };

      flake = mkOption {
        type = types.str;
        default = "";
        description = ''
          Flake URI to upgrade from.
          Example: "github:username/dotfiles" or use inputs.self.outPath for local flake.
        '';
      };

      dates = mkOption {
        type = types.str;
        default = "02:00";
        description = "When to run system upgrades (systemd time format).";
      };

      randomizedDelaySec = mkOption {
        type = types.str;
        default = "45min";
        description = "Random delay before upgrade to avoid thundering herd.";
      };

      flags = mkOption {
        type = types.listOf types.str;
        default = [
          "--update-input"
          "nixpkgs"
          "--no-write-lock-file"
          "-L" # Print build logs
        ];
        description = "Additional flags to pass to nixos-rebuild.";
      };
    };
  };

  config = mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = mkDefault true;
        max-jobs = mkDefault "auto";
        cores = mkDefault 0;
        trusted-users = [
          "root"
          "@wheel"
        ]
        ++ cfg.nix.settings.additionalTrustedUsers;

        # Build isolation
        sandbox = mkDefault true;

        # Keep build outputs/derivations for debugging (disabled by default to save space)
        keep-outputs = mkDefault false;
        keep-derivations = mkDefault false;

        # Warn about dirty git trees in flakes
        warn-dirty = mkDefault true;

        # Default binary cache
        substituters = mkDefault (
          [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ]
          ++ cfg.nix.settings.additionalSubstituters
        );

        # Automatic space-based garbage collection
        # Free up to max-free when available space drops below min-free
        min-free = mkDefault (100 * 1024 * 1024); # 100 MB
        max-free = mkDefault (1024 * 1024 * 1024); # 1 GB
      };

      gc = {
        automatic = cfg.nix.gc.automatic;
        dates = cfg.nix.gc.dates;
        options = cfg.nix.gc.options;
      };
    };

    # Automatic system upgrades (disabled by default)
    system.autoUpgrade = mkIf cfg.nix.autoUpgrade.enable {
      enable = true;
      flake = cfg.nix.autoUpgrade.flake;
      dates = cfg.nix.autoUpgrade.dates;
      randomizedDelaySec = cfg.nix.autoUpgrade.randomizedDelaySec;
      flags = cfg.nix.autoUpgrade.flags;
    };
  };
}

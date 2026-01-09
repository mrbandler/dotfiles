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
  options.${namespace}.core.swap = {
    zram = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable zram-based compressed swap in RAM.
          Much faster than disk swap and reduces SSD wear.
          Recommended for modern desktop systems with sufficient RAM.
          Note: If you need hibernation, you still need a disk swap partition.
        '';
      };

      memoryPercent = mkOption {
        type = types.int;
        default = 50;
        description = ''
          Maximum percentage of RAM that can be used for zram swap.
          Default is 50% (e.g., 8GB RAM = up to 4GB compressed swap).
          ZRAM only uses memory when swap is actually needed.
        '';
      };

      priority = mkOption {
        type = types.int;
        default = 5;
        description = ''
          Priority of zram swap devices.
          Higher priority swap is used first. Default disk swap priority is -2.
          A priority of 5 ensures zram is preferred over disk swap.
        '';
      };

      algorithm = mkOption {
        type = types.str;
        default = "zstd";
        description = ''
          Compression algorithm for zram.
          Options: zstd (best balance), lzo (faster, less compression), lz4 (very fast).
          zstd is recommended for most use cases.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    zramSwap = mkIf cfg.swap.zram.enable {
      enable = true;
      memoryPercent = cfg.swap.zram.memoryPercent;
      priority = cfg.swap.zram.priority;
      algorithm = cfg.swap.zram.algorithm;
    };
  };
}

{
  lib,
  ...
}:

with lib;
{
  options.internal.development.devDir = mkOption {
    type = types.str;
    default = "~/dev";
    description = "Base path for development directories. Used for identity contexts, direnv whitelist, etc.";
  };
}

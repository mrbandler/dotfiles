{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "direnv" ] [ "programs" "direnv" ])
  ];

  config.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      hide_env_diff = true;
      load_dotenv = true;
      warn_timeout = "10s";
      whitelist.prefix = [ config.internal.development.devDir ];
    };
  };
}

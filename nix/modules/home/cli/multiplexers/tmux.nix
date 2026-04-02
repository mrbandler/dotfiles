{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "multiplexers" "tmux" ] [ "programs" "tmux" ])
  ];

  config = {
    programs.tmux = {
    };
  };
}

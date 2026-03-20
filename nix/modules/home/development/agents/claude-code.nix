{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule
      [ "internal" "development" "agents" "claude-code" ]
      [ "programs" "claude-code" ]
    )
  ];
}

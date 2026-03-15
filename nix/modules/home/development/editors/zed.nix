{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "editors" "zed" ] [ "programs" "zed-editor" ])
  ];

  config = {
    programs.zed-editor = {
    };
  };
}

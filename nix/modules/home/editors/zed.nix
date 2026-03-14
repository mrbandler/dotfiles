{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "editors" "zed" ] [ "programs" "zed-editor" ])
  ];

  config = {
    programs.zed-editor = {
    };
  };
}

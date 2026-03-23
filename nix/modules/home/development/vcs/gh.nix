{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "vcs" "gh" ] [ "programs" "gh" ])
  ];

  config.programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}

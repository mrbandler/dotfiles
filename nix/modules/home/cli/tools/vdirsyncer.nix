{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "vdirsyncer" ] [ "programs" "vdirsyncer" ])
  ];

  config = {
    programs.vdirsyncer.enable = true;
    services.vdirsyncer = {
      enable = true;
      frequency = "*:0/1";
    };
  };
}

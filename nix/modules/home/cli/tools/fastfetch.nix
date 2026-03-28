{
  lib,
  config,
  ...
}:

with lib;
let
  themeName = config.internal.theme.colorScheme or "unknown";
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "fastfetch" ] [ "programs" "fastfetch" ])
  ];

  config.programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos";
        padding = { top = 1; };
      };
      display = {
        separator = " -> ";
      };
      modules = [
        "title"
        "separator"
        { type = "os"; key = "  OS"; }
        { type = "kernel"; key = "  Kernel"; }
        { type = "host"; key = "  Host"; }
        { type = "uptime"; key = "  Uptime"; }
        { type = "packages"; key = "  Pkgs"; }
        "break"
        { type = "cpu"; key = "  CPU"; }
        { type = "gpu"; key = "  GPU"; }
        { type = "memory"; key = "  RAM"; percent.type = 0; }
        { type = "disk"; key = "  Disk"; percent.type = 0; }
        "break"
        { type = "shell"; key = "  Shell"; }
        { type = "terminal"; key = "  Term"; }
        { type = "wm"; key = "  WM"; }
        { type = "command"; key = "  DE"; shell = "echo DankMaterialShell"; }
        { type = "terminalfont"; key = "  Font"; }
        { type = "command"; key = "  Theme"; shell = "echo ${themeName}"; }
        { type = "display"; key = "  Display"; compactType = "original-with-refresh-rate"; }
        "break"
        "colors"
      ];
    };
  };
}

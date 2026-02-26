{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  colors = config.lib.stylix.colors;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "desktop" "dms" ] [ "programs" "dank-material-shell" ])
  ];

  config = {
    programs.dank-material-shell = {
      enableDynamicTheming = false;
      systemd.enable = true;

      settings = {
        currentThemeName = "custom";
        customTheme = {
          dark = {
            name = "Stylix";
            primary = "#${colors.base0D}";
            primaryText = "#${colors.base00}";
            primaryContainer = "#${colors.base0D}";
            secondary = "#${colors.base0E}";
            surfaceTint = "#${colors.base0D}";
            surface = "#${colors.base01}";
            surfaceText = "#${colors.base05}";
            surfaceVariant = "#${colors.base02}";
            surfaceVariantText = "#${colors.base04}";
            surfaceContainer = "#${colors.base02}";
            surfaceContainerHigh = "#${colors.base03}";
            surfaceContainerHighest = "#${colors.base04}";
            background = "#${colors.base00}";
            backgroundText = "#${colors.base05}";
            outline = "#${colors.base03}";
            error = "#${colors.base08}";
            warning = "#${colors.base0A}";
            info = "#${colors.base0C}";
          };
        };
      };
    };
  };
}

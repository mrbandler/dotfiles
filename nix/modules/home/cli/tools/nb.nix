{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.nb;
  colors = config.lib.stylix.colors;

  # Convert a hex color (e.g., "cba6f7") to nearest xterm-256 color index.
  # The 6x6x6 color cube starts at index 16 and maps each channel to 0-5.
  hexToInt = c:
    let
      hexChars = {
        "0" = 0; "1" = 1; "2" = 2; "3" = 3;
        "4" = 4; "5" = 5; "6" = 6; "7" = 7;
        "8" = 8; "9" = 9;
        "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
        "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15;
      };
      chars = stringToCharacters c;
    in
      foldl' (acc: ch: acc * 16 + hexChars.${ch}) 0 chars;

  channelTo6 = v:
    if v < 48 then 0
    else if v < 115 then 1
    else (v - 35) / 40;

  hexTo256 = hex:
    let
      r = hexToInt (substring 0 2 hex);
      g = hexToInt (substring 2 2 hex);
      b = hexToInt (substring 4 2 hex);
    in
      16 + (channelTo6 r) * 36 + (channelTo6 g) * 6 + (channelTo6 b);
in
{
  options.internal.cli.tools.nb = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable nb command line note-taking and knowledge base";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nb ];

    home.sessionVariables = {
      NB_EDITOR = mkDefault "hx";
      NB_DEFAULT_EXTENSION = mkDefault "md";
      NB_AUTO_SYNC = mkDefault "1";
      NB_HEADER = mkDefault "2";
      NB_LIMIT = mkDefault "20";
      NB_COLOR_PRIMARY = mkDefault (toString (hexTo256 colors.base0D));
      NB_COLOR_SECONDARY = mkDefault (toString (hexTo256 colors.base04));
    };
  };
}

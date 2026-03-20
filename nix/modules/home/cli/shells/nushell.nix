{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "shells" "nushell" ] [ "programs" "nushell" ])
  ];

  config.programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      history = {
        file_format = "sqlite";
        max_size = 100000;
      };
      completions = {
        case_sensitive = false;
        partial = true;
        quick = true;
        algorithm = "fuzzy";
      };
      shell_integration = {
        osc2 = true;
        osc7 = true;
        osc133 = true;
        osc633 = true;
      };
    };
  };
}

{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "prompts" "starship" ] [ "programs" "starship" ])
  ];

  config.programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    presets = [ "nerd-font-symbols" ];
    settings = {
      format = "$shell$all$character";
      os.disabled = true;
      shell = {
        disabled = false;
        format = "$indicator in ";
        bash_indicator = "[bash](bold italic red)";
        nu_indicator = "[nu](bold italic green)";
      };
    };
  };
}

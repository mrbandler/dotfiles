{
  lib,
  config,
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
    presets = [ "catppuccin-powerline" ];
    settings = {
      os.disabled = true;
      shell = {
        disabled = false;
        nu_indicator = "nu";
        bash_indicator = "bash";
      };
    };
  };
}

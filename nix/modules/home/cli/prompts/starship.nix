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
      os.disabled = true;
    };
  };
}

{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.development.vcs;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "vcs" "gh" ] [ "programs" "gh" ])
  ];

  options.internal.development.vcs.ghToken = mkOption {
    type = types.nullOr types.str;
    default = ''op read "op://Development/gh/token"'';
    description = "Shell command to fetch the GH_TOKEN at shell init. Set to null to disable.";
  };

  config = {
    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    programs.bash.initExtra = mkIf (cfg.ghToken != null && config.programs.bash.enable) ''
      export GH_TOKEN=$(${cfg.ghToken})
    '';

    programs.nushell.extraConfig = mkIf (cfg.ghToken != null && config.programs.nushell.enable) ''
      $env.GH_TOKEN = (${cfg.ghToken})
    '';
  };
}

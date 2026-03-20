{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  vcsCfg = config.internal.development.vcs;
  cfg = vcsCfg.jj;

  # Generate TOML for context scopes
  contextScopes = concatStringsSep "\n" (mapAttrsToList (path: identity: ''
    [[--scope]]
    --when.repositories = ["${path}"]
    user.name = "${identity.name}"
    user.email = "${identity.email}"
  '') vcsCfg.identity.contexts);

  jjConfig = ''
    [user]
    name = "${vcsCfg.identity.default.name}"
    email = "${vcsCfg.identity.default.email}"

    ${optionalString vcsCfg.signing.enable ''
    [signing]
    sign-all = true
    backend = "ssh"
    key = "${vcsCfg.signing.publicKey}"

    [signing.backends.ssh]
    program = "${vcsCfg.signing.program}"
    ''}

    ${optionalString config.programs.delta.enable ''
    [ui]
    diff.tool = ["delta", "--paging=never"]
    pager = "delta"
    ''}

    ${contextScopes}
  '';
in
{
  options.internal.development.vcs.jj = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Jujutsu (jj) configuration";
    };

};

  config = mkIf (vcsCfg.enable && cfg.enable) {
    home.packages = [ pkgs.jujutsu ];

    home.file.".jjconfig.toml".text = jjConfig;
  };
}

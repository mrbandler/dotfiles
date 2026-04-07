{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.internal.cli.workflows.aliases;
in
{
  options.internal.cli.workflows.aliases = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Nushell shell aliases";
    };
  };

  config.programs.nushell.shellAliases = mkIf (cfg.enable && config.programs.nushell.enable) {
    # Modern replacements
    cat = "bat";
    df = "duf";
    du = "dust";

    # Git
    lg = "lazygit";
    gs = "git status";
    gd = "git diff";
    gl = "git log --oneline";
    gp = "git pull";
    gcm = "git commit -m";
    ga = "git add";

    # Editor
    zed = "zeditor";

    # System
    ff = "fastfetch";
    top = "btop";
    watch = "viddy";

    # Nix (nx shortcuts)
    nxr = "nx rebuild";
    nxb = "nx build";
    nxc = "nx check";
    nxs = "nx show";
    nxu = "nx update";
    nxg = "nx upgrade";

    # Container
    ld = "lazydocker";
    dk = "docker compose";
    dku = "docker compose up -d";
    dkd = "docker compose down";
    kk = "k9s";
  };
}

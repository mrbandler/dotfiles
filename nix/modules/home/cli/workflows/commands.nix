{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.internal.cli.workflows.commands;
  flakeDir = cfg.flakeDir;

  # -- Nushell custom commands --------------------------------------------------
  nushellCommands = ''
    # nx - Nix management commands

    def "nx rebuild" [] { nh os switch }
    def "nx rb" [] { nx rebuild }

    def "nx build" [] { nh os build }
    def "nx bd" [] { nx build }

    def "nx check" [] { cd ${flakeDir}; nix flake check }
    def "nx ck" [] { nx check }

    def "nx show" [] { cd ${flakeDir}; nix flake show }
    def "nx sw" [] { nx show }

    def "nx update" [] { cd ${flakeDir}; nix flake update }
    def "nx up" [] { nx update }

    def "nx update-input" [input: string] { cd ${flakeDir}; nix flake update $input }
    def "nx ui" [input: string] { nx update-input $input }

    def "nx upgrade" [] { nx update; nx rebuild }
    def "nx ug" [] { nx upgrade }

    def "nx rollback" [] { nh os switch --rollback }
    def "nx rlb" [] { nx rollback }

    def "nx history" [] { sudo nix-env --list-generations --profile /nix/var/nix/profiles/system }
    def "nx hy" [] { nx history }

    def "nx gc" [] { nh clean user }

    def "nx gc-all" [] { nh clean all }
    def "nx gca" [] { nx gc-all }

    def "nx optimize" [] { nix store optimise }
    def "nx opt" [] { nx optimize }

    def "nx search" [query: string] { nh search $query }
    def "nx sr" [query: string] { nx search $query }

    def "nx repl" [] { cd ${flakeDir}; nix repl . }
    def "nx rp" [] { nx repl }

    # nx top-level shortcuts
    def nxr [] { nx rebuild }
    def nxb [] { nx build }
    def nxc [] { nx check }
    def nxs [] { nx show }
    def nxu [] { nx update }
    def nxg [] { nx upgrade }

  '';

  # -- Bash function ------------------------------------------------------------
  bashCommands = ''
    # nx - Nix management commands
    nx() {
      local cmd="$1"
      shift 2>/dev/null

      case "$cmd" in
        rebuild|rb)   nh os switch ;;
        build|bd)     nh os build ;;
        check|ck)     (cd ${flakeDir} && nix flake check) ;;
        show|sw)      (cd ${flakeDir} && nix flake show) ;;
        update|up)    (cd ${flakeDir} && nix flake update) ;;
        update-input|ui) (cd ${flakeDir} && nix flake update "$1") ;;
        upgrade|ug)   nx update && nx rebuild ;;
        rollback|rlb) nh os switch --rollback ;;
        history|hy)   sudo nix-env --list-generations --profile /nix/var/nix/profiles/system ;;
        gc)           nh clean user ;;
        gc-all|gca)   nh clean all ;;
        optimize|opt) nix store optimise ;;
        search|sr)    nh search "$1" ;;
        repl|rp)      (cd ${flakeDir} && nix repl .) ;;
        *)
          echo "nx: unknown command '$cmd'"
          echo "Commands: rebuild(rb) build(bd) check(ck) show(sw) update(up)"
          echo "          update-input(ui) upgrade(ug) rollback(rlb) history(hy)"
          echo "          gc gc-all(gca) optimize(opt) search(sr) repl(rp)"
          return 1
          ;;
      esac
    }

    # nx top-level shortcuts
    alias nxr='nx rebuild'
    alias nxb='nx build'
    alias nxc='nx check'
    alias nxs='nx show'
    alias nxu='nx update'
    alias nxg='nx upgrade'
  '';
in
{
  options.internal.cli.workflows.commands = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable nx Nix management commands";
    };

    flakeDir = mkOption {
      type = types.str;
      default = "~/.dotfiles/nix";
      description = "Path to the Nix flake directory";
    };
  };

  config = mkIf cfg.enable {
    programs.nushell.extraConfig = mkIf config.programs.nushell.enable nushellCommands;
    programs.bash.initExtra = mkIf config.programs.bash.enable bashCommands;
  };
}

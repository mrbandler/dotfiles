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

    def "nx rebuild" [] { sudo nixos-rebuild switch --flake ${flakeDir}#(hostname) }
    def "nx rb" [] { nx rebuild }

    def "nx build" [] { nix build ($"${flakeDir}#nixosConfigurations." + (hostname) + ".config.system.build.toplevel") }
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

    def "nx rollback" [] { sudo nixos-rebuild switch --rollback }
    def "nx rlb" [] { nx rollback }

    def "nx history" [] { sudo nix-env --list-generations --profile /nix/var/nix/profiles/system }
    def "nx hy" [] { nx history }

    def "nx gc" [] { nix-collect-garbage }

    def "nx gc-all" [] { sudo nix-collect-garbage -d; nix-collect-garbage -d }
    def "nx gca" [] { nx gc-all }

    def "nx optimize" [] { nix store optimise }
    def "nx opt" [] { nx optimize }

    def "nx search" [query: string] { nix search nixpkgs $query }
    def "nx sr" [query: string] { nx search $query }

    def "nx repl" [] { cd ${flakeDir}; nix repl . }
    def "nx rp" [] { nx repl }

  '';

  # -- Bash function ------------------------------------------------------------
  bashCommands = ''
    # nx - Nix management commands
    nx() {
      local cmd="$1"
      shift 2>/dev/null

      case "$cmd" in
        rebuild|rb)   sudo nixos-rebuild switch --flake ${flakeDir}#$(hostname) ;;
        build|bd)     nix build "${flakeDir}#nixosConfigurations.$(hostname).config.system.build.toplevel" ;;
        check|ck)     (cd ${flakeDir} && nix flake check) ;;
        show|sw)      (cd ${flakeDir} && nix flake show) ;;
        update|up)    (cd ${flakeDir} && nix flake update) ;;
        update-input|ui) (cd ${flakeDir} && nix flake update "$1") ;;
        upgrade|ug)   nx update && nx rebuild ;;
        rollback|rlb) sudo nixos-rebuild switch --rollback ;;
        history|hy)   sudo nix-env --list-generations --profile /nix/var/nix/profiles/system ;;
        gc)           nix-collect-garbage ;;
        gc-all|gca)   sudo nix-collect-garbage -d && nix-collect-garbage -d ;;
        optimize|opt) nix store optimise ;;
        search|sr)    nix search nixpkgs "$1" ;;
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

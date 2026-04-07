{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.internal.cli.workflows.pipelines;

  pipelineCommands = ''
    # ed - Open $EDITOR
    def ed [...args: string] { run-external $env.EDITOR ...$args }

    # find - Browse files with tv and bat syntax-highlighted preview
    def find [path?: string] {
      if ($path != null) {
        tv files $path -p "bat --color=always --style=plain {}"
      } else {
        tv files -p "bat --color=always --style=plain {}"
      }
    }

    # search - Search file contents with ripgrep via tv
    def search [path?: string] {
      if ($path != null) {
        tv ripgrep $path
      } else {
        tv ripgrep
      }
    }

    # ports - Show listening ports with process info
    def ports [port?: int] {
      let raw = (ss -tlnp | lines | skip 1 | each { |line|
        let parts = ($line | split row -r '\s+')
        let listen = ($parts | get 3 | default "")
        let idx = ($listen | str index-of ":" -e)
        let addr = if ($idx >= 0) {
          { address: ($listen | str substring 0..($idx - 1) | str trim -l -c '[' | str trim -r -c ']'), port: ($listen | str substring ($idx + 1)..) }
        } else {
          { address: $listen, port: "" }
        }
        let proc = ($parts | get 5? | default "" | parse -r 'users:\(\("(?<name>[^"]+)",pid=(?<pid>\d+)' | get 0? | default { name: "-", pid: "-" })
        {
          proto: ($parts | get 0)
          address: $addr.address
          port: ($addr.port | into int)
          process: $proc.name
          pid: $proc.pid
        }
      })
      if ($port != null) {
        $raw | where port == $port
      } else {
        $raw | sort-by port
      }
    }
  '';

  bashPipelineCommands = ''
    # ports - Show listening ports with process info
    ports() {
      if [ -n "$1" ]; then
        ss -tlnp | awk -v port="$1" 'NR>1 { split($4, a, ":"); p=a[length(a)]; if (p == port) print }'
      else
        ss -tlnp
      fi
    }
  '';
in
{
  options.internal.cli.workflows.pipelines = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable fuzzy find and search pipelines";
    };
  };

  config = mkIf cfg.enable {
    programs.nushell.extraConfig = mkIf config.programs.nushell.enable pipelineCommands;
    programs.bash.initExtra = mkIf config.programs.bash.enable bashPipelineCommands;
  };
}

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
        let addr = if ($listen | str contains "]:") {
          let split = ($listen | split row "]:")
          { address: ($split | get 0 | str trim -l -c '['), port: ($split | get 1) }
        } else if ($listen | str contains ":") {
          let split = ($listen | split row ":")
          { address: ($split | drop last 1 | str join ":"), port: ($split | last) }
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
in
{
  options.internal.cli.workflows.pipelines = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable fuzzy find and search pipelines";
    };
  };

  config.programs.nushell.extraConfig = mkIf (cfg.enable && config.programs.nushell.enable) pipelineCommands;
}

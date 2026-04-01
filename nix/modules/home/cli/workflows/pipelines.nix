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

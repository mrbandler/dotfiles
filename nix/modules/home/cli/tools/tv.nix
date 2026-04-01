{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.internal.cli.tools.tv;
  bat = "${pkgs.bat}/bin/bat";
  rg = "${pkgs.ripgrep}/bin/rg";

  # Shared action keybindings for all channels
  actionKeybindings = ''
    [keybindings]
    ctrl-e = "actions:edit"
    ctrl-o = "actions:visual"
  '';

  # Editor actions for file-based channels
  fileActions = ''
    [actions.edit]
    description = "Open in $EDITOR"
    command = "$EDITOR '{}'"
    mode = "execute"

    [actions.visual]
    description = "Open in $VISUAL"
    command = "$VISUAL '{}'"
    mode = "execute"
  '';
in
{
  options.internal.cli.tools.tv = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable television fuzzy finder";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.television ];

    xdg.configFile."television/config.toml".text = ''
      [ui.preview_panel]
      border_type = "rounded"
    '';

    # Override built-in files channel with editor actions
    xdg.configFile."television/cable/files.toml".text = ''
      [metadata]
      name = "files"
      description = "Find files"
      requirements = ["fd"]

      [source]
      command = "fd --type f --hidden --follow"

      [preview]
      command = "${bat} --color=always --style=plain {}"

      ${actionKeybindings}

      ${fileActions}
    '';

    # Ripgrep search channel
    xdg.configFile."television/cable/ripgrep.toml".text = ''
      [metadata]
      name = "ripgrep"
      description = "Search file contents with ripgrep"
      requirements = ["rg", "bat"]

      [source]
      command = "${rg} --line-number --color=never --field-match-separator='\t' ."

      [preview]
      command = "${bat} --color=always --style=numbers --highlight-line {split:\t:1} {split:\t:0}"
      offset = "{split:\t:1}"

      [keybindings]
      ctrl-e = "actions:edit"
      ctrl-o = "actions:visual"
      shortcut = "ctrl-s"

      [actions.edit]
      description = "Open at line in $EDITOR"
      command = "$EDITOR +{split:\t:1} '{split:\t:0}'"
      mode = "execute"

      [actions.visual]
      description = "Open at line in $VISUAL"
      command = "$VISUAL '{split:\t:0}:{split:\t:1}'"
      mode = "execute"
    '';
  };
}

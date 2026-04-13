{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "development" "editors" "zed" ] [ "programs" "zed-editor" ])
  ];

  config.programs.zed-editor = {
    mutableUserSettings = true;

    userSettings = {
      auto_update = false;
      autosave = "on_focus_change";
      autoscroll_on_clicks = true;
      cursor_shape = "underline";
      buffer_font_weight = 400.0;
      preferred_line_length = 120;
      relative_line_numbers = "enabled";
      redact_private_values = true;
      use_smartcase_search = true;
      use_system_prompts = false;
      use_system_path_prompts = false;
      wrap_guides = [
        80
        100
        120
      ];
      helix_mode = false;

      window_decorations = "client";
      bottom_dock_layout = "contained";

      tabs = {
        file_icons = true;
        git_status = true;
      };

      title_bar.show_branch_icon = true;
      diagnostics.button = true;

      terminal = {
        show_count_badge = false;
        cursor_shape = "underline";
        shell.program = "nu";
        dock = "right";
        button = true;
      };

      status_bar = {
        cursor_position_button = true;
        active_encoding_button = "enabled";
        active_language_button = true;
      };

      project_panel = {
        hide_root = false;
        diagnostic_badges = true;
        bold_folder_labels = false;
        button = true;
      };

      search.center_on_match = true;

      indent_guides = {
        active_line_width = 2;
        line_width = 1;
      };

      toolbar.quick_actions = false;

      sticky_scroll.enabled = true;

      which_key = {
        delay_ms = 500;
        enabled = true;
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      icon_theme = "Catppuccin Macchiato";
      edit_predictions.provider = "copilot";
    };

    extensions = [
      "catppuccin-icons"
      "csharp"
      "csv"
      "docker-compose"
      "dockerfile"
      "gdscript"
      "git-firefly"
      "glsl"
      "html"
      "ini"
      "just"
      "lua"
      "markdownlint"
      "nim"
      "nix"
      "nu"
      "proto"
      "qml"
      "sql"
      "terraform"
      "toml"
      "typst"
      "xml"
    ];
  };
}

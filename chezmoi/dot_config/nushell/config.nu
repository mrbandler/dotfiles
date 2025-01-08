use keybindings.nu *
use menus.nu *
use aliases.nu *
use themes/catpuccin.nu
use scripts/state.nu

source zoxide.nu

let dark_theme = catpuccin "macchiato"
let light_theme = catpuccin "latte"

$env.config = {
    show_banner: false
    ls: {
        use_ls_colors: true
        clickable_links: true
    }
    rm: {
        always_trash: true
    }
    table: {
        mode: rounded,
        index_mode: always
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: false
    }
    error_style: "fancy"
    display_errors: {
        exit_code: false
        termination_signal: true
    }
    datetime_format: {
        normal: '%a, %d %b %Y %H:%M:%S %z'
        table: '%d.%m.%y %H:%M:%S'
    }
    explore: {
        status_bar_background: { fg: "#1D1F21", bg: "#C4C9C6" },
        command_bar_text: { fg: "#C4C9C6" },
        highlight: { fg: "black", bg: "yellow" },
        status: {
            error: { fg: "white", bg: "red" },
            warn: {}
            info: {}
        },
        selected_cell: { bg: light_blue },
    }
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
        sort: "smart"
        external: {
            enable: true
            max_results: 100
            completer: null # check 'carapace_completer' above as an example
        }
        use_ls_colors: true
    }
    filesize: {
        metric: false
        format: "auto"
    }
    cursor_shape: {
        emacs: blink_underscore
        vi_insert: blink_underscore
        vi_normal: blink_underscore
    }
    color_config: $dark_theme
    footer_mode: auto
    float_precision: 2
    buffer_editor: "nvim"
    use_ansi_coloring: true
    bracketed_paste: true
    edit_mode: emacs
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: false
        osc633: true
        reset_application_mode: true
    }
    render_right_prompt_on_last_line: false
    use_kitty_protocol: false
    highlight_resolved_externals: false
    recursion_limit: 50
    plugins: {} # Per-plugin configuration. See https://www.nushell.sh/contributor-book/plugins.html#configuration.
    plugin_gc: {
        default: {
            enabled: true
            stop_after: 10sec
        }
        plugins: {
            # alternate configuration for specific plugins, by name, for example:
            #
            # gstat: {
            #     enabled: false
            # }
        }
    }
    hooks: {
        pre_prompt: [{ null }]
        pre_execution: [{ null }]
        env_change: {
            PWD: [{|before, after| null }]
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: { null }
    }
    menus: $menus
    keybindings: $keybindings
}

const palettes = {
    latte: {
        rosewater: "#dc8a78"
        flamingo: "#dd7878"
        pink: "#ea76cb"
        mauve: "#8839ef"
        red: "#d20f39"
        maroon: "#e64553"
        peach: "#fe640b"
        yellow: "#df8e1d"
        green: "#40a02b"
        teal: "#179299"
        sky: "#04a5e5"
        sapphire: "#209fb5"
        blue: "#1e66f5"
        lavender: "#7287fd"
        text: "#4c4f69"
        subtext1: "#5c5f77"
        subtext0: "#6c6f85"
        overlay2: "#7c7f93"
        overlay1: "#8c8fa1"
        overlay0: "#9ca0b0"
        surface2: "#acb0be"
        surface1: "#bcc0cc"
        surface0: "#ccd0da"
        base: "#eff1f5"
        mantle: "#e6e9ef"
        crust: "#dce0e8"
    },
    frape: {
        rosewater: "#f2d5cf"
        flamingo: "#eebebe"
        pink: "#f4b8e4"
        mauve: "#ca9ee6"
        red: "#e78284"
        maroon: "#ea999c"
        peach: "#ef9f76"
        yellow: "#e5c890"
        green: "#a6d189"
        teal: "#81c8be"
        sky: "#99d1db"
        sapphire: "#85c1dc"
        blue: "#8caaee"
        lavender: "#babbf1"
        text: "#c6d0f5"
        subtext1: "#b5bfe2"
        subtext0: "#a5adce"
        overlay2: "#949cbb"
        overlay1: "#838ba7"
        overlay0: "#737994"
        surface2: "#626880"
        surface1: "#51576d"
        surface0: "#414559"
        base: "#303446"
        mantle: "#292c3c"
        crust: "#232634"
    },
    macchiato: {
        rosewater: "#f4dbd6"
        flamingo: "#f0c6c6"
        pink: "#f5bde6"
        mauve: "#c6a0f6"
        red: "#ed8796"
        maroon: "#ee99a0"
        peach: "#f5a97f"
        yellow: "#eed49f"
        green: "#a6da95"
        teal: "#8bd5ca"
        sky: "#91d7e3"
        sapphire: "#7dc4e4"
        blue: "#8aadf4"
        lavender: "#b7bdf8"
        text: "#cad3f5"
        subtext1: "#b8c0e0"
        subtext0: "#a5adcb"
        overlay2: "#939ab7"
        overlay1: "#8087a2"
        overlay0: "#6e738d"
        surface2: "#5b6078"
        surface1: "#494d64"
        surface0: "#363a4f"
        base: "#24273a"
        mantle: "#1e2030"
        crust: "#181926"
    },
    mocha: {
        rosewater: "#f5e0dc"
        flamingo: "#f2cdcd"
        pink: "#f5c2e7"
        mauve: "#cba6f7"
        red: "#f38ba8"
        maroon: "#eba0ac"
        peach: "#fab387"
        yellow: "#f9e2af"
        green: "#a6e3a1"
        teal: "#94e2d5"
        sky: "#89dceb"
        sapphire: "#74c7ec"
        blue: "#89b4fa"
        lavender: "#b4befe"
        text: "#cdd6f4"
        subtext1: "#bac2de"
        subtext0: "#a6adc8"
        overlay2: "#9399b2"
        overlay1: "#7f849c"
        overlay0: "#6c7086"
        surface2: "#585b70"
        surface1: "#45475a"
        surface0: "#313244"
        base: "#1e1e2e"
        mantle: "#181825"
        crust: "#11111b"
    }
}

export def main [name: string] {
    let palette = (if ($name in $palettes) {
        $palettes | get $name
    } else {
        $palettes | get "mocha"
    })

    return {
        separator: $palette.overlay0
        leading_trailing_space_bg: { attr: "n" }
        header: { fg: $palette.blue attr: "b" }
        empty: $palette.lavender
        bool: $palette.lavender
        int: $palette.peach
        duration: $palette.text
        filesize: {|e|
            if $e < 1mb {
                $palette.green
            } else if $e < 100mb {
                $palette.yellow
            } else if $e < 500mb {
                $palette.peach
            } else if $e < 800mb {
                $palette.maroon
            } else if $e > 800mb {
                $palette.red
            }
        }
        date: {|| (date now) - $in |
            if $in < 1hr {
                $palette.green
            } else if $in < 1day {
                $palette.yellow
            } else if $in < 3day {
                $palette.peach
            } else if $in < 1wk {
                $palette.maroon
            } else if $in > 1wk {
                $palette.red
            }
        }
        range: $palette.text
        float: $palette.text
        string: $palette.text
        nothing: $palette.text
        binary: $palette.text
        cellpath: $palette.text
        row_index: { fg: $palette.mauve attr: "b" }
        record: $palette.text
        list: $palette.text
        block: $palette.text
        hints: $palette.overlay1
        search_result: { fg: $palette.red bg: $palette.text }

        shape_and: { fg: $palette.pink attr: "b" }
        shape_binary: { fg: $palette.pink attr: "b" }
        shape_block: { fg: $palette.blue attr: "b" }
        shape_bool: $palette.teal
        shape_custom: $palette.green
        shape_datetime: { fg: $palette.teal attr: "b" }
        shape_directory: $palette.teal
        shape_external: $palette.teal
        shape_externalarg: { fg: $palette.green attr: "b" }
        shape_filepath: $palette.teal
        shape_flag: { fg: $palette.blue attr: "b" }
        shape_float: { fg: $palette.pink attr: "b" }
        shape_garbage: { fg: $palette.text bg: $palette.red attr: "b" }
        shape_globpattern: { fg: $palette.teal attr: "b" }
        shape_int: { fg: $palette.pink attr: "b" }
        shape_internalcall: { fg: $palette.teal attr: "b" }
        shape_list: { fg: $palette.teal attr: "b" }
        shape_literal: $palette.blue
        shape_match_pattern: $palette.green
        shape_matching_brackets: { attr: "u" }
        shape_nothing: $palette.teal
        shape_operator: $palette.peach
        shape_or: { fg: $palette.pink attr: "b" }
        shape_pipe: { fg: $palette.pink attr: "b" }
        shape_range: { fg: $palette.peach attr: "b" }
        shape_record: { fg: $palette.teal attr: "b" }
        shape_redirection: { fg: $palette.pink attr: "b" }
        shape_signature: { fg: $palette.green attr: "b" }
        shape_string: $palette.green
        shape_string_interpolation: { fg: $palette.teal attr: "b" }
        shape_table: { fg: $palette.blue attr: "b" }
        shape_variable: $palette.pink

        background: $palette.base
        foreground: $palette.text
        cursor: $palette.blue
    }
}

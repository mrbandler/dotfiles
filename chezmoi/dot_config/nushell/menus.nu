export const menus = [
    {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: { attr: r }
            description_text: yellow
            match_text: { attr: u }
            selected_match_text: { attr: ur }
        }
    }
    {
        name: ide_completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: ide
            min_completion_width: 0,
            max_completion_width: 50,
            max_completion_height: 10,
            padding: 0,
            border: true,
            cursor_offset: 0,
            description_mode: "prefer_right"
            min_description_width: 0
            max_description_width: 50
            max_description_height: 10
            description_offset: 1
            correct_cursor_pos: false
        }
        style: {
            text: green
            selected_text: { attr: r }
            description_text: yellow
            match_text: { attr: u }
            selected_match_text: { attr: ur }
        }
    }
    {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
    }
    {
        name: help_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
    }
]

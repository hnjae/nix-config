# Based on https://github.com/kovidgoyal/kitty/blob/master/kitty/tab_bar.py
# License of the file: GPL3

from typing import TYPE_CHECKING

from kitty.tab_bar import as_rgb, draw_title

if TYPE_CHECKING:
    from kitty.fast_data_types import Screen
    from kitty.tab_bar import DrawData, ExtraData, TabBarData
    from kitty.tab_bar.typing import PowerlineStyle


powerline_symbols: dict["PowerlineStyle", tuple[str, str]] = {
    # "slanted": ("", ""),
    "slanted": ("", "", ""),
    "round": ("", ""),
}


def draw_tab(
    draw_data: "DrawData",
    screen: "Screen",
    tab: "TabBarData",
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: "ExtraData",
) -> int:
    tab_bg = screen.cursor.bg
    tab_fg = screen.cursor.fg
    default_bg = as_rgb(int(draw_data.default_bg))
    if extra_data.next_tab:
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = default_bg
        needs_soft_separator = False

    separator_symbol, soft_separator_symbol_l, soft_separator_symbol_r = (
        powerline_symbols.get(draw_data.powerline_style, ("", ""))
    )
    min_title_length = 1 + 2
    start_draw = 2

    if screen.cursor.x == 0:
        screen.cursor.bg = tab_bg
        screen.draw(" ")
        start_draw = 1

    screen.cursor.bg = tab_bg
    if min_title_length >= max_tab_length:
        screen.draw("…")
    else:
        draw_title(draw_data, screen, tab, index, max_tab_length)
        extra = screen.cursor.x + start_draw - before - max_tab_length
        if extra > 0 and extra + 1 < screen.cursor.x:
            screen.cursor.x -= extra + 1
            screen.draw("…")

    if not needs_soft_separator:
        screen.draw(" ")
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
        screen.draw(separator_symbol)
    else:
        prev_fg = screen.cursor.fg
        # if tab_bg == tab_fg:
        #     screen.cursor.fg = default_bg
        # elif tab_bg != default_bg:
        #     c1 = draw_data.inactive_bg.contrast(draw_data.default_bg)
        #     c2 = draw_data.inactive_bg.contrast(draw_data.inactive_fg)
        #     if c1 < c2:
        #         screen.cursor.fg = default_bg
        screen.cursor.fg = tab_fg
        screen.cursor.bold = True
        screen.draw(f" {soft_separator_symbol}")
        screen.cursor.bold = False
        # screen.draw(" ")
        # screen.cursor.bg = screen.cursor.fg
        screen.cursor.fg = prev_fg

    end = screen.cursor.x
    if end < screen.columns:
        screen.draw(" ")
    return end

    return screen.cursor.x

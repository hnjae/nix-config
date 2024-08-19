# Based on https://github.com/kovidgoyal/kitty/blob/master/kitty/tab_bar.py
# License of the file: GPL3

from typing import TYPE_CHECKING

from kitty.tab_bar import as_rgb, draw_title
from kitty.fast_data_types import get_options
from kitty.utils import color_as_int

if TYPE_CHECKING:
    from kitty.fast_data_types import Screen
    from kitty.tab_bar import DrawData, ExtraData, TabBarData
    from kitty.tab_bar.typing import PowerlineStyle


powerline_symbols: dict["PowerlineStyle", tuple[str, str]] = {
    # "slanted": ("", ""),
    "slanted": (
        "",
        "",
        "",
    ),
    # "round": ("", ""),
    "round": ("", "", ""),
}

opts = get_options()
tab_bar_bg = as_rgb(color_as_int(opts.tab_bar_background or opts.background))

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
    # tab_fg = screen.cursor.fg
    default_bg = as_rgb(int(draw_data.default_bg))
    if extra_data.next_tab:
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = default_bg
        needs_soft_separator = False

    separator_symbol, soft_separator_symbol_l, soft_separator_symbol_r = (
        powerline_symbols.get(draw_data.powerline_style, ("", "", ""))
    )
    min_title_length = 1 + 2

    if screen.cursor.x == 0:
        screen.cursor.bg = tab_bg
        screen.draw(" ")
        start_draw = 1
    else:
        prev_fg = screen.cursor.fg
        screen.cursor.bg = tab_bg
        screen.cursor.fg = tab_bar_bg
        screen.draw(f"{soft_separator_symbol_l} ")
        screen.cursor.fg = prev_fg
        start_draw = 0

    screen.cursor.bg = tab_bg
    if min_title_length >= max_tab_length:
        screen.draw("…")
    else:
        draw_title(draw_data, screen, tab, index, max_tab_length)
        extra = screen.cursor.x + start_draw - before - max_tab_length
        if extra > 0 and extra + 1 < screen.cursor.x:
            screen.cursor.x -= extra + 1
            screen.draw("…")

    prev_fg = screen.cursor.fg
    prev_bg = screen.cursor.bg
    screen.cursor.fg = tab_bar_bg
    screen.cursor.bg = tab_bg
    screen.draw(f" {soft_separator_symbol_r}")

    if not needs_soft_separator:
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
    else:
        screen.cursor.fg = prev_fg
        screen.cursor.bg = prev_bg

    end = screen.cursor.x
    return end

/***
    Copyright (c) 2019 Jeremy Wootten <https://github.com/jeremypw/widget-grid>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program. If not, see <http://www.gnu.org/licenses/>.

    Authors: Jeremy Wootten <jeremy@elementaryos.org>
***/

namespace WidgetGrid {
public interface PositionHandler : Object {
    protected abstract void position_items (int first_displayed_row, double offset);
    protected abstract int get_row_height (int widget_index, int data_index);

    public abstract bool get_row_col_at_pos (int x, int y, out int row, out int col);
    public abstract WidgetData get_data_at_row_col (int row, int col);
    public abstract Item get_item_at_row_col (int row, int col);
}
}

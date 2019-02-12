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

/*** The PositionHandler interface contains functions associated with determining the correct position
     of items, the dimensions of rows, and retrieving items from position data.
***/
namespace WidgetGrid {
public interface PositionHandler : Object {
    public abstract Gee.AbstractList<RowData> row_data { get; set; }
    public abstract Gee.AbstractList<Item> widget_pool { get; construct; }
    public abstract WidgetGrid.Model<WidgetData> model { get; construct; }

    public abstract int vpadding { get; set; default = 24;}
    public abstract int hpadding { get; set; default = 12;}
    public abstract int cols { get; set; }
    public abstract int item_width { get; set; }
    public int column_width {
        get {
            return item_width + hpadding + vpadding;
        }
    }

    protected abstract void position_items (int first_displayed_row, double offset);
    protected abstract void update_item_with_data (Item item, WidgetData data);
    protected abstract int next_widget_index (int current_index);

    public bool get_row_col_at_pos (int x, int y, out int row, out int col) {
        bool on_item = true;
        double cc = double.min ((double)(cols - 1), (double)x / (double)column_width);
        double x_offset = cc - (int)cc;

        if (x_offset < hpadding || x_offset > hpadding + item_width) {
            on_item = false;
        }

        int index = 0;

        while (index < (row_data.size - 1) && row_data[index].y < y) {
            index++;
        }

        if (index > 0) {
            index--;
        }

        var y_offset = y - row_data[index].y;

        if (y_offset < vpadding || y_offset > row_data[index].height - vpadding) {
            on_item = false;
        }

        row = index;
        col = (int)cc;

        return on_item;
    }

    public virtual WidgetData get_data_at_row_col (int row, int col) {
       return model.lookup_index (row_data[row].first_data_index + col);
    }

    public virtual Item get_item_at_row_col (int row, int col) {
       return widget_pool[(row_data[row].first_widget_index + col)];
    }

    /** @index is the index of the last item on the previous row (or -1 for the first row) **/
    protected virtual int get_row_height (int widget_index, int data_index) { /* widgets previous updated */
        var max_h = 0;

        for (int c = 0; c < cols && data_index < model.get_n_items (); c++) {
            var item = widget_pool[widget_index];
            var data = model.lookup_index (data_index);
            update_item_with_data (item, data);

            int min_h, nat_h, min_w, nat_w;
            item.get_preferred_width (out min_w, out nat_w);
            item.get_preferred_height_for_width (min_w, out min_h, out nat_h);

            if (nat_h > max_h) {
                max_h = nat_h;
            }

            widget_index = next_widget_index (widget_index);
            data_index++;
        }

        return max_h + 2 * vpadding;
    }
}
}

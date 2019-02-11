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
public interface LayoutSelectionHandler : Object, PositionHandler {
    /* We can assume only one rubberbanding operation will occur at a time */
    private static int previous_last_rubberband_row = 0;
    private static int previous_last_rubberband_col = 0;

    public abstract SelectionFrame frame { get; construct; }
    public abstract bool rubber_banding { get; set; default = false; }
    public abstract bool can_rubber_band { get; set; default = true; }
    public abstract Gee.TreeSet<WidgetData> selected_data { get; construct; }

    public abstract Gtk.Widget get_widget ();

    public virtual void do_rubber_banding (Gdk.EventMotion event) {
        if (!can_rubber_band) {
            return;
        }

        var x = (int)(event.x);
        var y = (int)(event.y);

        if (!rubber_banding) {
            frame.initialize (x, y);
        } else {
            var new_width = x - frame.x;
            var new_height = y - frame.y;
            var new_x = frame.x;
            var new_y = frame.y;

            if (new_width < 0) {
                new_x = x;
                new_width = -new_width;
            }

            if (new_height < 0) {
                new_y = y;
                new_height = -new_height;
            }

            frame.update (new_x, new_y, new_width, new_height);
            mark_selected_in_rectangle ();
            get_widget ().queue_draw ();
        }

        rubber_banding = true;
    }

    public virtual void end_rubber_banding () {
        LayoutSelectionHandler.previous_last_rubberband_row = 0;
        LayoutSelectionHandler.previous_last_rubberband_col = 0;

        rubber_banding = false;
        frame.close ();
        get_widget ().queue_draw ();
    }

    protected Gdk.Rectangle get_framed_rectangle () {
        return frame.get_rectangle ();
    }

    protected virtual void mark_selected_in_rectangle () {
        int first_row, first_col;
        int previous_last_row = LayoutSelectionHandler.previous_last_rubberband_row;
        int previous_last_col = LayoutSelectionHandler.previous_last_rubberband_col;

        get_row_col_at_pos (frame.x, frame.y, out first_row, out first_col);

        int last_row, last_col;
        get_row_col_at_pos (frame.x + frame.width, frame.y + frame.height, out last_row, out last_col);

        for (int r = first_row; r <= int.max (last_row, previous_last_row); r++) {
            for (int c = first_col; c <= int.max (last_col, previous_last_col); c++) {
                var data = get_data_at_row_col (r, c);
                var to_select = (r <= last_row && c <= last_col);
                if (data.is_selected != to_select) {
                    var item = get_item_at_row_col (r, c);
                    data.is_selected = to_select;
                    item.update_item (data);
                    if (to_select) {
                        selected_data.add (data);
                    } else {
                        selected_data.remove (data);
                    }
                }
            }
        }

        previous_last_rubberband_col = last_col;
        previous_last_rubberband_row = last_row;
    }

    public virtual bool draw_rubberband (Cairo.Context ctx) {
        if (rubber_banding) {
            frame.draw (ctx);
        }

        return false;
    }

    public virtual void clear_selection () {
        selected_data.clear ();
        reset_selected_data ();
    }

    protected abstract void reset_selected_data ();
}
}

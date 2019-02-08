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

public class View : Gtk.Grid {
    private const int MIN_ITEM_WIDTH = 32;
    private const int MAX_ITEM_WIDTH = 512;
    private const int MAX_WIDGETS = 1000;

    private Gtk.Layout layout;
    private Gtk.Adjustment vadjustment;
    private double SCROLL_SENSITIVITY = 0.5;
    private const double ZOOM_SENSITIVITY = 0.5;
    private const int SCROLL_REDRAW_DELAY_MSEC = 100;
    private double accel = 1.0;
    private const double MAX_ACCEL = 128.0;
    private const double ACCEL_RATE = 1.3;

    public Vala.ArrayList <Item> widget_pool;
    public Model<WidgetData>model {get; set; }
    public int n_items = 0;
    public int n_widgets = 0;
    public int pool_size = 0;
    private int first_displayed_data_index = 0;
    private int first_displayed_widget_index = 0;
    private int last_displayed_data_index = 0;
    private int highest_displayed_widget_index = 0;
    private int first_displayed_row_height = 0;
    private double last_adjustment_val = 0.0;

    private double offset = 0.0;
    private int cols = 0;
    private int total_rows = 0;
    public int column_width { get; private set; }
    private int[] row_offsets;

    public int[] allowed_item_widths = {16, 24, 32, 48, 64, 96, 128, 256, 512};
    public int width_increment { get; set; default = 6; }
    public int minimum_item_width { get; set; default = MIN_ITEM_WIDTH; }
    public int maximum_item_width { get; set; default = MAX_ITEM_WIDTH; }
    public bool fixed_item_widths = true;

    private int _item_width = MIN_ITEM_WIDTH;
    public int item_width {
        get {
            return _item_width;
        }

        set {
            int new_width = 0;
            var n_allowed = allowed_item_widths.length;
            if (fixed_item_widths && n_allowed > 0) {
                var width = value.clamp (minimum_item_width, maximum_item_width);
                var index = 0;
                while (index < n_allowed && (new_width < minimum_item_width || new_width < width)) {
                    new_width = allowed_item_widths[index++];
                }

                item_width_index = index - 1;
                new_width = allowed_item_widths[item_width_index];
            } else {
                new_width = value.clamp (minimum_item_width, maximum_item_width);
            }

            _item_width = new_width;
        }
    }

    public int item_width_index { get; private set; }
    public bool force_item_width { get; set; default = false; }
    public int hpadding { get; set; default = 6; }
    public int vpadding { get; set; default = 6; }

    public AbstractItemFactory factory { get; construct; }

    public signal void selection_changed ();

    construct {
        vadjustment = new Gtk.Adjustment (0.0, 0.0, 10.0, 1.0, 1.0, 1.0);
        var scrollbar = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, vadjustment);
        scrollbar.set_slider_size_fixed (true);

        layout = new Gtk.Layout ();
        layout.hexpand = true;
        layout.vexpand = true;
        hexpand = true;
        vexpand = true;
        orientation = Gtk.Orientation.HORIZONTAL;
        add (layout);
        add (scrollbar);

        row_offsets = new int[100];
        for (int i = 0; i < 100; i++) {
            row_offsets[i] = int.MAX;
        }

        widget_pool = new Vala.ArrayList<Item> ();

        item_width_index = 3;
        column_width = item_width + hpadding + hpadding;

        notify["hpadding"].connect (() => {
            column_width = item_width + hpadding + hpadding;
        });

        notify["vpadding"].connect (() => {
            reflow ();
        });

        notify["column-width"].connect (() => {
            reflow ();
        });

        notify["item-width"].connect (() => {
            column_width = item_width + hpadding + hpadding;
        });

        vadjustment.value_changed.connect (on_adjustment_value_changed);

        size_allocate.connect ((alloc) => {
            reflow (alloc);
        });

        layout.add_events (Gdk.EventMask.SCROLL_MASK | Gdk.EventMask.SMOOTH_SCROLL_MASK | Gdk.EventMask.POINTER_MOTION_MASK);
        layout.scroll_event.connect ((event) => {
            var control_pressed = (event.state & Gdk.ModifierType.CONTROL_MASK) != 0;

            if (!control_pressed) {
                return handle_scroll (event);
            } else {
                return handle_zoom (event);
            }
        });

        layout.can_focus = true;

        layout.key_press_event.connect (on_key_press_event);

        layout.delete_event.connect (() => {
            if (scroll_redraw_timeout_id > 0) {
                Source.remove (scroll_redraw_timeout_id);
            }

            if (reflow_timeout_id > 0) {
                Source.remove (reflow_timeout_id);
            }

            return false;
        });

        show_all ();
    }

    public View (AbstractItemFactory _factory, Model<WidgetData>? _model = null) {
        Object (factory: _factory,
                model: _model != null ? _model : new SimpleModel ()
        );
    }

    private bool on_key_press_event (Gdk.EventKey event) {
        var control_pressed = (event.state & Gdk.ModifierType.CONTROL_MASK) != 0;
        if (control_pressed) {
            switch (event.keyval) {
                case Gdk.Key.plus:
                case Gdk.Key.equal:
                    zoom_in ();
                    return true;

                case Gdk.Key.minus:
                    zoom_out ();
                    return true;

                default:
                    break;
            }
        }

        return false;
    }

    private bool handle_scroll (Gdk.EventScroll event) {
        switch (event.direction) {
            case Gdk.ScrollDirection.SMOOTH:
                double delta_x, delta_y;
                event.get_scroll_deltas (out delta_x, out delta_y);
                /* try to emulate a normal scrolling event by summing deltas.
                 * step size of 0.5 chosen to match sensitivity */
                total_delta_y += delta_y;

                if (total_delta_y >= SCROLL_SENSITIVITY) {
                    total_delta_y = 0.0;
                    vadjustment.set_value (vadjustment.get_value () + vadjustment.get_step_increment () * accel);
                } else if (total_delta_y <= -SCROLL_SENSITIVITY) {
                    total_delta_y = 0.0;
                    vadjustment.set_value (vadjustment.get_value () - vadjustment.get_step_increment () * accel);
                }

                return true;

            default:
                return false;
        }
    }

    private bool handle_zoom (Gdk.EventScroll event) {
       switch (event.direction) {
            case Gdk.ScrollDirection.UP:
                zoom_in ();
                return true;

            case Gdk.ScrollDirection.DOWN:
                zoom_out ();
                return true;

            case Gdk.ScrollDirection.SMOOTH:
                double delta_x, delta_y;
                event.get_scroll_deltas (out delta_x, out delta_y);
                /* try to emulate a normal scrolling event by summing deltas.
                 * step size of 0.5 chosen to match sensitivity */
                total_delta_y += delta_y;

                if (total_delta_y >= ZOOM_SENSITIVITY) {
                    total_delta_y = 0;
                    zoom_out ();
                } else if (total_delta_y <= -ZOOM_SENSITIVITY) {
                    total_delta_y = 0;
                    zoom_in ();
                }
                return true;

            default:
                return false;
        }
    }

    private void zoom_in () {
        if (fixed_item_widths) {
            if (item_width_index < allowed_item_widths.length - 1) {
                item_width = allowed_item_widths[++item_width_index];
            }
        } else {
            item_width += width_increment;
        }
    }

    private void zoom_out () {
        if (fixed_item_widths) {
            if (item_width_index >= 1) {
                item_width = allowed_item_widths[--item_width_index];
            }
        } else {
            item_width -= width_increment;
        }
    }

    private double total_delta_y = 0.0;

    /*** Implement accelerating scrolling ***/
    private uint scroll_redraw_timeout_id = 0;
    private bool wait = false;
    private uint32 last_event_time = 0;
    private void on_adjustment_value_changed () {
        var now = Gtk.get_current_event_time ();
        uint32 rate = now - last_event_time;  /* min about 24, typical 50 - 150 */
        last_event_time = now;

        if (rate > 300) {
            accel = 1.0;
        } else {
            accel += (ACCEL_RATE / 300 * (300 - rate));
        }

        do_scroll_redraw ();

        if (scroll_redraw_timeout_id > 0) {
            wait = true;
            return;
        } else {
            wait = false;
            scroll_redraw_timeout_id = Timeout.add (SCROLL_REDRAW_DELAY_MSEC, () => {
                if (wait) {
                    wait = false;
                    accel /= ACCEL_RATE;
                    return Source.CONTINUE;
                } else {
                    scroll_redraw_timeout_id = 0;
                    accel = 1.0;
                    return Source.REMOVE;
                }
            });
        }
    }

    private void do_scroll_redraw () {
       var new_val = vadjustment.get_value ();
        bool up = new_val < last_adjustment_val;
        var first_displayed_row = (int)(new_val);

        if (up) {
            var row_height = (get_row_height (first_displayed_widget_index, first_displayed_data_index));
            offset = (new_val - (double)first_displayed_row) * row_height;
        } else {
            offset = (new_val - (double)first_displayed_row) * first_displayed_row_height;
        }

        Idle.add (() => {position_items (first_displayed_row); return false;});
        last_adjustment_val = new_val;
    }

    private uint reflow_timeout_id = 0;
    private bool block_reflow = true;
    private void schedule_reflow () {
        if (reflow_timeout_id > 0) {
            block_reflow = true;
            return;
        } else {
            reflow_timeout_id = Timeout.add (300, () => {
                if (block_reflow) {
                    block_reflow = false;
                    return Source.CONTINUE;
                } else {
                    reflow ();
                    reflow_timeout_id = 0;
                    return Source.REMOVE;
                }
            });
        }
    }

    public void add_data (WidgetData data) {
        if (n_items < MAX_WIDGETS) {
            widget_pool.add (factory.new_item ());
            n_widgets++;
        }

        data.data_id = n_items;
        model.add (data);
        n_items++;
        schedule_reflow ();
    }


    /** @index is the index of the last item on the previous row (or -1 for the first row) **/
    private int get_row_height (int widget_index, int data_index) { /* widgets previous updated */
        var max_h = 0;

        for (int c = 0; c < cols && data_index < n_items; c++) {
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

    private void update_item_with_data (Item item, WidgetData data) {
        if (item.data_id != data.data_id) {
            item.update_item (data);
        }

        item.set_max_width (item_width);
    }

    private void position_items (int first_displayed_row) {
        int data_index, widget_index, row_height;

        data_index = first_displayed_row * cols;
        if (n_items == 0 || data_index >= n_items)  {
            return;
        } else if (data_index < 0) {
            data_index = 0;
            offset = 0;
        }

        if (first_displayed_data_index != data_index) {
            clear_layout ();
            first_displayed_data_index = data_index;
            first_displayed_widget_index = first_displayed_data_index % (highest_displayed_widget_index + 1);
            last_displayed_data_index = first_displayed_data_index;
        }

        first_displayed_row_height = get_row_height (first_displayed_widget_index, first_displayed_data_index);
        row_height = first_displayed_row_height;
        widget_index = first_displayed_widget_index;
        data_index = first_displayed_data_index;

        int y = 0 - (int)offset;
        for (int r = 0; y < layout.get_allocated_height () && data_index < n_items; r++) {
            int x = 0;
            for (int c = 0; c < cols && data_index < n_items; c++) {
                var item = widget_pool[widget_index];
                int xx = x + hpadding;
                int yy = y + vpadding;

                if (item.get_parent () != null) {
                    layout.move (item, xx, yy);
                } else {
                    layout.put (item, xx, yy);
                }

                x += column_width;

                last_displayed_data_index = data_index;
                highest_displayed_widget_index = int.max (highest_displayed_widget_index, widget_index);
                widget_index = next_widget_index (widget_index);
                data_index++;
            }

            row_offsets[r] = y;
            y += row_height;
            row_height = get_row_height (widget_index, data_index);
        }

        var items_displayed = last_displayed_data_index - first_displayed_data_index + 1;
        pool_size = int.max (pool_size, items_displayed + 2 * cols - items_displayed % cols);
        pool_size = pool_size.clamp (0, n_widgets - 1);

        queue_draw ();
    }

    private void reflow (Gtk.Allocation? alloc = null) {
        if (column_width == 0 || block_reflow) {
            return;
        }

        cols = layout.get_allocated_width () / column_width;

        if (cols == 0) {
            return;
        }

        var new_total_rows = (n_items) / cols + 1;
        if (total_rows != new_total_rows) {
            clear_layout ();

            total_rows = new_total_rows;

            var first_displayed_row = first_displayed_data_index / cols;

            highest_displayed_widget_index = 0;
            last_displayed_data_index = 0;
            offset = 0.0;
            pool_size = 0;

            var val = first_displayed_row;
            var min_val = 0.0;
            var max_val = (double)(total_rows + 1);
            var step_increment = 0.05;
            var page_increment = 1.0;
            var page_size = 5.0;
            vadjustment.configure (val, min_val, max_val, step_increment, page_increment, page_size);
            on_adjustment_value_changed ();
        }
    }

    private void clear_layout () {
        Value val = {};
        val.init (typeof (int));
        /* Removing is slow so first move out of window if current displayed else remove */
        int removed = 0;
        int moved = 0;
        foreach (unowned Gtk.Widget w in layout.get_children ()) {
            layout.child_get_property (w, "x", ref val);
            if (val.get_int () < -500) {
                layout.remove (w);
                removed++;
            } else {
                layout.move (w, -1000, -1000);
                moved++;
            }
        }
    }

    private int next_widget_index (int widget_index) {
        widget_index++;

        if (widget_index > (pool_size > 0 ? pool_size : n_widgets - 1)) {
            widget_index = 0;
        }

        return widget_index;
    }

    public void sort (CompareDataFunc? func) {
        model.sort (func);
        queue_draw ();
    }
}
}

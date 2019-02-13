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

/*** WidgetGrid.View handles layout and scrollbar, adding items to and sorting the model, and reacting
     to some user input. The details of laying out the widgets in a grid, scrolling and zooming them is
     passed off to the WidgetGrid.LayoutHandler.
*
     View is under an EventBox in order to capture events before they reach the displayed widgets to allow
     rubberbanding and to emit special signals depending on where the event occured (on item or on background).
     It is up to the App to deal with these signals appropriately, e.g. by displaying a context menu.
***/
namespace WidgetGrid {

public class View : Gtk.EventBox {
    private static int total_items_added = 0; /* Used to ID data; only ever increases */
    private const int MIN_ITEM_WIDTH = 32;
    private const int MAX_ITEM_WIDTH = 512;

    private const double SCROLL_SENSITIVITY = 0.5; /* The scroll delta required to move the grid position by one step */
    private const double ZOOM_SENSITIVITY = 1.0; /* The scroll delta required to change the item width by one step */

    private Gtk.Layout layout;
    private LayoutHandler layout_handler;

    public Model<WidgetData>model {get; set construct; }
    public AbstractItemFactory factory { get; construct; }

    public int[] allowed_item_widths = {16, 24, 32, 48, 64, 96, 128, 256, 512};
    public int width_increment { get; set; default = 6; }
    public int minimum_item_width { get; set; default = MIN_ITEM_WIDTH; }
    public int maximum_item_width { get; set; default = MAX_ITEM_WIDTH; }
    public int item_width_index { get; private set; }
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

    public int hpadding { get; set; default = 6; }
    public int vpadding { get; set; default = 6; }

    public signal void selection_changed ();
    public signal void item_clicked (Item item, Gdk.EventButton event);
    public signal void background_clicked (Gdk.EventButton event);

    construct {
        set_above_child (true);

        var grid = new Gtk.Grid ();
        grid.hexpand = true;
        grid.vexpand = true;
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        item_width_index = 3;

        layout = new Gtk.Layout ();
        layout.hexpand = true;
        layout.vexpand = true;
        layout.can_focus = true;

        layout_handler = new LayoutHandler (layout, factory, model);

        bind_property ("item-width", layout_handler, "item-width", BindingFlags.DEFAULT);
        bind_property ("hpadding", layout_handler, "hpadding", BindingFlags.DEFAULT);
        bind_property ("vpadding", layout_handler, "vpadding", BindingFlags.DEFAULT);

        var scrollbar = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, layout_handler.vadjustment);
        scrollbar.set_slider_size_fixed (true);

        grid.add (layout);
        grid.add (scrollbar);
        add (grid);

        size_allocate.connect (() => {
            layout_handler.configure ();
        });

        add_events (Gdk.EventMask.SCROLL_MASK |
                    Gdk.EventMask.SMOOTH_SCROLL_MASK |
                    Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK |
                    Gdk.EventMask.POINTER_MOTION_MASK
        );

        scroll_event.connect ((event) => {
            if ((event.state & Gdk.ModifierType.CONTROL_MASK) == 0) { /* Control key not pressed */
                return handle_scroll (event);
            } else {
                return handle_zoom (event);
            }
        });

        key_press_event.connect (on_key_press_event);

        button_press_event.connect ((event) => {
            int x = (int)(event.x);
            int y = (int)(event.y);

            var item = layout_handler.get_item_at_pos (x, y);
            var on_item = item != null;

            if (event.button == Gdk.BUTTON_PRIMARY &&
                layout_handler.can_rubber_band &&
                !on_item) {

                layout_handler.start_rubber_banding (event);
            } else if (on_item) {
                item_clicked (item, event);
            } else {
                background_clicked (event);
            }
        });

        button_release_event.connect ((event) => {
            layout_handler.end_rubber_banding ();
        });

        delete_event.connect (() => {
            layout_handler.close ();
            return false;
        });

        motion_notify_event.connect ((event) => {
            if ((event.state & Gdk.ModifierType.BUTTON1_MASK) > 0) {
                layout_handler.do_rubber_banding (event);
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

    public void add_data (WidgetData data) {
        data.data_id = View.total_items_added;
        model.add (data);
        View.total_items_added++;
    }

    public void sort (CompareDataFunc? func) {
        model.sort (func);
        queue_draw ();
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
        } else {
            switch (event.keyval) {
                case Gdk.Key.Escape:
                    layout_handler.clear_selection ();
                    break;

                default:
                    break;
            }
        }

        return false;
    }

    private double total_delta_y = 0.0;
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
                    layout_handler.scroll_steps (1);
                } else if (total_delta_y <= -SCROLL_SENSITIVITY) {
                    total_delta_y = 0.0;
                    layout_handler.scroll_steps (-1);
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

    public override bool draw (Cairo.Context ctx) {
        base.draw (ctx);
        return layout_handler.draw_rubberband (ctx);
    }

    public WidgetData[] get_selected () {
        return layout_handler.selected_data.to_array ();
    }
}
}

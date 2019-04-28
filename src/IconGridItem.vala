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

/*** WidgetGrid.Item interface defines the characteristics needed by a widget to be used
     for display by WidgetGrid.View and generated by a WidgetGrid.ItemFactory.
***/

namespace FM {
public enum ClickZone {
    EXPANDER,
    HELPER,
    ICON,
    NAME,
    BLANK_PATH,
    BLANK_NO_PATH,
    INVALID
}
}

namespace WidgetGridDemo {
public class IconGridItem : Gtk.EventBox, WidgetGrid.Item {
    private static int _max_height;
    public static int max_height { get { return _max_height; } set { _max_height = value; } default = 256;}
    private static int _min_height;
    public static int min_height { get { return _min_height; } set { _min_height = value; } default = 16;}

    private const Gtk.IconSize default_helper_size = Gtk.IconSize.SMALL_TOOLBAR;
    private const Gtk.IconSize focused_helper_size = Gtk.IconSize.LARGE_TOOLBAR;

    static construct {
        WidgetGrid.Item.min_height = 16;
        WidgetGrid.Item.max_height = 256;
    }

    private Gtk.Grid grid;
    private Gtk.Overlay overlay;
    private Gtk.Frame frame;
    private Gtk.Image icon;
    private Gtk.Image helper;
    private Gdk.Rectangle helper_allocation;
    private Gtk.Label label;
    private int set_max_width_request = 0;
    private int total_padding;

    public WidgetGrid.DataInterface data { get; set; default = null; }

    public Gdk.Pixbuf? pix {
        get {
            return file != null ? file.pix : null;
        }
    }

    public string item_name {
        get {
            return file != null ? file.get_display_name () : "";
        }
    }

    public bool is_hovered { get; set; default = false; }
    public bool is_selected { get {return data != null ? data.is_selected : false;} }
    public bool is_cursor_position { get {return data != null ? data.is_cursor_position : false;} }
    public uint64 data_id { get {return data != null ? data.data_id : -1;} }
    public GOF.File? file { get { return data != null ? ((DemoItemData)data).file : null; } }

    construct {
        overlay = new Gtk.Overlay ();
        frame = new Gtk.Frame (null);
        frame.shadow_type = Gtk.ShadowType.OUT;
        frame.halign = Gtk.Align.CENTER;
        frame.show_all ();

        grid = new Gtk.Grid ();
        grid.margin = 2;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.CENTER;
        grid.hexpand = true;

        icon = new Gtk.Image.from_pixbuf (pix);
        icon.margin_top = icon.margin_bottom = 6;
        icon.halign = Gtk.Align.CENTER;

        label = new Gtk.Label (item_name);
        label.halign = Gtk.Align.CENTER;
        label.vexpand = true;
        label.margin_top = label.margin_bottom = 6;
        label.set_line_wrap (true);
        label.set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
        label.set_ellipsize (Pango.EllipsizeMode.END);
        label.set_lines (5);
        label.set_justify (Gtk.Justification.CENTER);

        helper = new Gtk.Image ();
        helper.margin = 0;
        helper.set_from_icon_name ("selection-add", Gtk.IconSize.LARGE_TOOLBAR);
        helper.halign = Gtk.Align.START;
        helper.valign = Gtk.Align.START;
        helper.show_all ();

        grid.add (icon);
        grid.add (label);

        overlay.add (grid);
        overlay.add_overlay (helper);

        frame.add (overlay);

        add (frame);

        add_events (Gdk.EventMask.BUTTON_PRESS_MASK);

        button_press_event.connect ((event) => {
            int x = (int)(event.x);
            int y = (int)(event.y);
            var zone = get_zone  ({x, y});

            if (zone == FM.ClickZone.HELPER) {
                data.is_selected = !data.is_selected;
                update_state ();
            }

            return false;
        });

        overlay.get_child_position.connect (on_get_child_position);

        total_padding += margin_start;
        total_padding += frame.margin_start;
        total_padding += grid.margin_start;
        total_padding += icon.margin_start;
        total_padding += margin_end;
        total_padding += frame.margin_end;
        total_padding += grid.margin_end;
        total_padding += icon.margin_end;

        show_all ();
    }

    public IconGridItem (DemoItemData? data = null) {
        Object (data: data);
    }

    private bool on_get_child_position (Gtk.Widget widget, out Gdk.Rectangle allocation) {
        allocation = Gtk.Allocation ();
        var w_alloc = Gtk.Allocation ();
        frame.get_allocation (out w_alloc);
        allocation.x = w_alloc.x;
        allocation.y = w_alloc.y;
        allocation.width = 24;
        allocation.height = 24;

        helper_allocation = (Gdk.Rectangle)allocation;
        return true;
    }

    public bool get_new_pix (int size) {
        if (size < 16) {
            size = 16;
        }

        icon.set_size_request (size, size);

        if (file != null) {
            file.update_icon (size, 1);
        }

        icon.set_from_pixbuf (pix);

        return true;
    }

    public bool equal (WidgetGrid.Item b) {
        if (b is IconGridItem) {
            return (( IconGridItem) b).item_name == item_name;
        } else {
            return false;
        }
    }

    public bool set_max_width (int width, bool force = false) {
        if (width != set_max_width_request || force) {
            get_new_pix (width - total_padding);
            set_max_width_request = width;
        }

        set_size_request (width, -1);

        return true;
    }

    /** Call with null to refresh from existing data **/
    public void update_item (WidgetGrid.DataInterface? _data = null) {
        if (_data != null) {
            assert (_data is DemoItemData);
            data = _data;
        }
        update_state ();
        label.label = item_name;
        set_max_width (set_max_width_request, true);
    }

    /** The point supplied must be in widget coordinates **/
    public FM.ClickZone get_zone (Gdk.Point p) {
        var p_rect = Gdk.Rectangle () {x = p.x, y = p.y, width = 1, height = 1};
        FM.ClickZone result = FM.ClickZone.BLANK_NO_PATH;

        if (helper_allocation.intersect (p_rect, null)) {
            result = FM.ClickZone.HELPER;
        } else if (label.intersect (p_rect, null)) {
            result = FM.ClickZone.NAME;
        } else if (icon.intersect (p_rect, null)) {
            result = FM.ClickZone.ICON;
        } else if (frame.intersect (p_rect, null)){
            result = FM.ClickZone.BLANK_PATH;
        }

        return result;
    }

    private void update_state () {
        if (is_selected) {
            grid.set_state_flags (Gtk.StateFlags.SELECTED, false);
            helper.set_from_icon_name ("selection-checked", default_helper_size);
        } else {
            grid.unset_state_flags (Gtk.StateFlags.SELECTED);
        }

        if (is_cursor_position) {
            grid.set_state_flags (Gtk.StateFlags.PRELIGHT, false);
            helper.set_from_icon_name (is_selected ? "selection-remove" : "selection-add", focused_helper_size);
        } else {
            grid.unset_state_flags (Gtk.StateFlags.PRELIGHT);
        }

        helper.visible = is_cursor_position || is_selected || is_hovered;
    }

    public void left () {
        update_state ();
    }

    public void leave () {
        is_hovered = false;
        update_state ();
    }

    public void hovered (Gdk.EventMotion event) {
        update_state ();
    }

    public void enter () {
        is_hovered = true;
        update_state ();
    }
}
}

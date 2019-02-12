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

/*** A demo ItemFactory which generates widgets suitable for display in WidgetGrid.View and which
     display the icon and name of a GOF.File (supplied as a Widgetdata). The Item is zoomable and clickable
     and its appearance changes when hovered.
***/
namespace WidgetGrid {

public class DemoItemFactory : AbstractItemFactory {
    public override Item new_item () {
        return new DemoItem ();
    }

    protected class DemoItem : Gtk.EventBox, Item {
        static construct {
            Item.min_height = 16;
            Item.max_height = 256;
        }

        private Gtk.Image image;
        private Gtk.Label label;
        private int set_max_width_request = 0;
        private int total_padding;

        public WidgetData? data { get; set; default = null; }

        private DemoItemData? demo_data {
            get {
                return data != null ? (DemoItemData)data : null;
            }
        }

        public Gdk.Pixbuf? pix {
            get {
                return data != null ? file.pix : null;
            }
        }

        private bool highlighted = false;
        public bool focused { get; set; default = false; }

        public string item_name {
            get {
                return data != null ? file.get_display_name () : "";
            }
        }

        public int data_id {
            get {
                return data != null ? data.data_id : -1;
            }
        }
        public GOF.File? file {
            get {
                return data != null ? demo_data.file : null;
            }
        }

        construct {
            var grid = new Gtk.Grid ();
            total_padding += grid.margin * 2;
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.halign = Gtk.Align.CENTER;
            grid.valign = Gtk.Align.CENTER;

            image = new Gtk.Image.from_pixbuf (pix);
            image.margin = 2;
            total_padding += image.margin * 2;

            label = new Gtk.Label (item_name);
            label.halign = Gtk.Align.CENTER;
            label.margin = 2;
            total_padding += label.margin * 2;
            label.set_line_wrap (true);
            label.set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
            label.set_ellipsize (Pango.EllipsizeMode.END);
            label.set_lines (5);
            label.set_justify (Gtk.Justification.CENTER);

            grid.add (image);
            grid.add (label);
            add (grid);

            notify["focused"].connect (() => {
                if (focused && !highlighted) {
                    highlight (true);
                } else if (!focused && highlighted) {
                    highlight (false);
                }
            });

            add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
            button_press_event.connect (on_button_press);

            enter_notify_event.connect ((event) => {
                focused = true;
            });

            leave_notify_event.connect ((event) => {
               focused = false;
            });

            show_all ();
        }

        public bool get_new_pix (int size) {
            if (file != null) {
                file.update_icon (size, 1);
            }

            /* Temporary */
            if (pix == null) {
                image.set_from_icon_name ("image-missing", Gtk.IconSize.SMALL_TOOLBAR);
            } else {
                image.set_from_pixbuf (pix);
            }

            return true;
        }

        public bool set_max_width (int width) {
            if (width != set_max_width_request) {
                get_new_pix (width - total_padding);
                set_max_width_request = width;
            }

            set_size_request (width, -1);

            return true;
        }

        public void update_item (WidgetData? new_data = null) {
            if (new_data != null) {
                this.data = new_data;
            }

            if (data != null) {
                set_selected (data.is_selected);
                label.label = item_name;
            }

            set_max_width_request = 0; /* Ensure pix will be updated when next used */
        }

        private void toggle_selected () {
            is_selected = !is_selected;
            set_selected (is_selected);
        }

        private void set_selected (bool selected) {
            if (data != null) {
                data.is_selected = selected;
            }
            var flags = selected ? Gtk.StateFlags.SELECTED : Gtk.StateFlags.NORMAL;
            set_state_flags (flags, true);
        }

        private bool on_button_press (Gdk.EventButton event) {
            switch (event.button) {
                case Gdk.BUTTON_PRIMARY:
                    toggle_selected ();
                    return true;

                case Gdk.BUTTON_SECONDARY:
                    show_properties ();
                    return true;

                default:
                    return false;
            }
        }

        private void show_properties () {

        }

        private void highlight (bool is_highlight) {
            if (is_highlight) {
                image.set_from_pixbuf (PF.PixbufUtils.lighten (pix));
                highlighted = true;
            } else {
                image.set_from_pixbuf (pix);
                highlighted = false;
            }
        }
    }
}
}




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

public class DemoItemFactory : AbstractItemFactory {
    private static int widget_id = 0;

    public override Item new_item () {
        var w = new DemoItem (null);
        w.id = widget_id++;
        return w;
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

        public int id { get; set; default = -1;}

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

        public bool is_selected { get; set; default = false; }
        public int data_id { get; set; default = -1; }
        public GOF.File? file { get; set; default = null; }

        construct {
            var frame = new Gtk.Frame (null);
            frame.shadow_type = Gtk.ShadowType.OUT;
            total_padding += frame.margin * 2;

            var grid = new Gtk.Grid ();
            total_padding += grid.margin * 2;
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.halign = Gtk.Align.CENTER;
            grid.valign = Gtk.Align.CENTER;

            image = new Gtk.Image.from_pixbuf (pix);
            image.margin = 6;
            total_padding += image.margin * 2;

            label = new Gtk.Label (item_name);
            label.halign = Gtk.Align.CENTER;
            label.margin = 6;
            total_padding += label.margin * 2;
            label.set_line_wrap (true);
            label.set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
            label.set_ellipsize (Pango.EllipsizeMode.END);
            label.set_lines (5);
            label.set_justify (Gtk.Justification.CENTER);

            grid.add (image);
            grid.add (label);

            frame.add (grid);

            add (frame);

            button_press_event.connect (() => {
                warning ("button press %s", item_name);
            return false;
            });

            show_all ();
        }

        public DemoItem (GOF.File? file) {
            Object (file: file);
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

        public bool is_equal (Item b) {
            if (b is DemoItem) {
                return (( DemoItem) b).item_name == item_name;
            } else {
                return false;
            }
        }

        public bool set_max_width (int width) {
            if (width != set_max_width_request) {
                get_new_pix (width - total_padding);
                set_max_width_request = width;
            }

            set_size_request (width, -1);

            return true;
        }

        public void update_item (Data data) {
            assert (data is DemoItemData);
            var demo_data = (DemoItemData)data;

            file = demo_data.file;
            data_id = data.data_id;
            label.label = item_name;
            set_max_width_request = 0;
        }
    }
}
}




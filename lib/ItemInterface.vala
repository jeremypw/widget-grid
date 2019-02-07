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

public interface Item : Gtk.Widget {
    public abstract bool is_selected { get; set; default = false; }
    public abstract int data_id { get; set; default = -1; }
    public abstract bool set_max_width (int width);

    private static int _max_height;
    public static int max_height { get { return _max_height; } set { _max_height = value; } default = 256;}
    private static int _min_height;
    public static int min_height { get { return _min_height; } set { _min_height = value; } default = 16;}

    public abstract void get_preferred_height_for_width (int width, out int min_height, out int nat_height);
    public abstract bool equal (Item b);

    public abstract void update_item (Data data);
}
}

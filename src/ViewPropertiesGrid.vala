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
public class ViewPropertiesGrid : Gtk.Grid {
    public string view_path { get; construct; }
    public View view { get; construct; }

    public signal void hpadding_changed (int new_hpad);
    public signal void vpadding_changed (int new_vpad);

    construct {
        var path_klabel = new KeyLabel ("Path");
        var path_vlabel = new ValueLabel (view_path);

        var hpad_klabel = new KeyLabel ("Column Padding");
        var hpad_scale = new ValueIntScale (12, 72, 6, view.hpadding);

        var vpad_klabel = new KeyLabel ("Row Padding");
        var vpad_scale = new ValueIntScale (12, 72, 6, view.vpadding);

        attach (path_klabel, 0, 0, 1, 1);
        attach_next_to (path_vlabel, path_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (hpad_klabel, 0, 1, 1, 1);
        attach_next_to (hpad_scale, hpad_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (vpad_klabel, 0, 2, 1, 1);
        attach_next_to (vpad_scale, vpad_klabel, Gtk.PositionType.RIGHT, 1, 1);

        hpad_scale.value_changed.connect (() => {
            hpadding_changed ((int)(hpad_scale.get_value ()));
        });

        vpad_scale.value_changed.connect (() => {
            vpadding_changed ((int)(vpad_scale.get_value ()));
        });

        show_all ();
    }

    public ViewPropertiesGrid (string path, View view) {
        Object (view_path: path,
                view: view);
    }
}
}

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

namespace WidgetGridDemo {
public class ViewPropertiesGrid : Gtk.Grid {
    public string view_path { get; construct; }
    public WidgetGrid.View view { get; construct; }

    public signal void hpadding_changed (int new_hpad);
    public signal void vpadding_changed (int new_vpad);

    construct {
        var path_klabel = new KeyLabel ("Path");
        var path_vlabel = new ValueLabel (view_path);

        var hpad_klabel = new KeyLabel ("Column Padding");
        var hpad_scale = new ValueIntScale (12, 72, 6, view.hpadding);

        var vpad_klabel = new KeyLabel ("Row Padding");
        var vpad_scale = new ValueIntScale (12, 72, 6, view.vpadding);

        var fixed_item_widths_klabel = new KeyLabel ("Fix widths");
        var fixed_item_widths_switch = new ValueSwitch (view.fixed_item_widths);

        var item_width_klabel = new KeyLabel ("Item width request");
        var item_width_scale = new ValueIntScale (8, view.maximum_item_width, view.width_increment, view.item_width);

        var item_width_increment_klabel = new KeyLabel ("Width request step");
        var width_increment_scale = new ValueIntScale (1, 8, 1, view.width_increment);

        var fixed_widths_array_klabel = new KeyLabel ("Allowed widths array");
        string[] width_arrays = {"24, 48, 64", "48, 96, 256", "16, 32, 48, 64, 128, 256, 512"};
        var sb = new StringBuilder ("");
        foreach (int i in view.get_allowed_widths ()) {
            sb.append (i.to_string () + ", ");
        }

        sb.truncate (sb.len - 2);
        var fixed_widths_array_combo = new ValueStringCombo (width_arrays, sb.str);

        attach (path_klabel, 0, 0, 1, 1);
        attach_next_to (path_vlabel, path_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (hpad_klabel, 0, 1, 1, 1);
        attach_next_to (hpad_scale, hpad_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (vpad_klabel, 0, 2, 1, 1);
        attach_next_to (vpad_scale, vpad_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (fixed_item_widths_klabel, 0, 3, 1, 1);
        attach_next_to (fixed_item_widths_switch, fixed_item_widths_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (item_width_klabel, 0, 4, 1, 1);
        attach_next_to (item_width_scale, item_width_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (item_width_increment_klabel, 0, 5, 1, 1);
        attach_next_to (width_increment_scale, item_width_increment_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (fixed_widths_array_klabel, 0, 6, 1, 1);
        attach_next_to (fixed_widths_array_combo, fixed_widths_array_klabel, Gtk.PositionType.RIGHT, 1, 1);

        hpad_scale.value_changed.connect (() => {
            hpadding_changed ((int)(hpad_scale.get_value ()));
        });

        vpad_scale.value_changed.connect (() => {
            vpadding_changed ((int)(vpad_scale.get_value ()));
        });

        fixed_item_widths_switch.state_set.connect ((state) => {
            view.fixed_item_widths = state;

            item_width_scale.sensitive = !state;
            width_increment_scale.sensitive = !state;
        });

        item_width_scale.value_changed.connect (() => {
            view.item_width = (int)(item_width_scale.get_value ());
        });

        width_increment_scale.value_changed.connect (() => {
            view.width_increment = (int)(width_increment_scale.get_value ());
            item_width_scale.configure (8, view.maximum_item_width, view.width_increment, view.item_width);
        });

        fixed_item_widths_switch.set_state (view.fixed_item_widths);

        fixed_widths_array_combo.changed.connect (() => {
            GLib.Regex non_num;

            try {
                non_num = new GLib.Regex ("[^0-9]+");
            } catch (Error e) {
                critical ("Regex error %s", e.message);
                return;
            }

            var txt = fixed_widths_array_combo.get_active_text ();
            var width_text_array = non_num.split (txt);
            var width_array = new int[width_text_array.length];
            int index = 0;
            foreach (string s in width_text_array) {
                int i = int.parse(s).clamp (view.minimum_item_width, view.maximum_item_width);
                width_array[index] = i;
                index++;
            }

            view.set_allowed_widths (width_array);
        });

        show_all ();
    }

    public ViewPropertiesGrid (string path, WidgetGrid.View view) {
        Object (view_path: path,
                view: view);
    }
}
}

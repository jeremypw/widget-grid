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
public class KeyLabel : Gtk.Label {
    public KeyLabel (string label) {
        Object (halign: Gtk.Align.END,
                label: label,
                valign: Gtk.Align.BASELINE,
                margin: 6);

        get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
    }
}

public class ValueLabel : Gtk.Label {
    public ValueLabel (string label) {
        Object (can_focus: true,
                halign: Gtk.Align.START,
                valign: Gtk.Align.BASELINE,
                label: label,
                margin: 6
        );

        get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
    }
}

public class ValueIntScale : Gtk.Scale {
    public ValueIntScale (int min, int max, int step, int val) {
        Object (can_focus: true,
                halign: Gtk.Align.START,
                valign: Gtk.Align.BASELINE,
                adjustment: new Gtk.Adjustment ((double)val, (double)min, (double)max, (double)step, 1, 1),
                digits: 0,
                value_pos: Gtk.PositionType.RIGHT,
                margin: 6,
                margin_end: 12
        );

        set_size_request (150 , -1);

        get_style_context ().add_class (Gtk.STYLE_CLASS_SCALE_HAS_MARKS_BELOW);
    }

    public void configure (int min, int max, int step, int val) {
        get_adjustment ().configure ((double)val, (double)min, (double)max, (double)step, 1, 1);
    }
}

public class ValueSwitch : Gtk.Switch {
    public ValueSwitch (bool on) {
        Object (
            state: on,
            hexpand: false,
            vexpand: false
        );
    }
}

public class ValueStringCombo : Gtk.ComboBoxText {
    public ValueStringCombo (string[] strings, string current_string) {
        Object (has_entry: true);

        int index = 0;
        bool current_in_list = false;
        foreach (string s in strings) {
            append (index.to_string (), s);
            if (current_string == s) {
                current_in_list = true;
                set_active (index);
            }

            index++;
        }

        if (!current_in_list) {
            prepend (index.to_string (), current_string);
            set_active (0);
        }

        show_all ();
    }
}
}

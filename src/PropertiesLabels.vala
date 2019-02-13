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
                label: label
        );

        get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
    }
}
}

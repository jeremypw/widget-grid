
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
   public class AppMenu : Gtk.MenuButton {
        public signal void change_view (ViewType type);

        construct {
            var popover = new Gtk.Popover (this);
            var listbox = new Gtk.ListBox ();

            listbox.add (make_viewtype_button ("Simple Unsorted View", ViewType.SIMPLE));
            listbox.add (make_viewtype_button ("Simple Sorted View", ViewType.SIMPLE_SORTED));
            listbox.add (make_viewtype_button ("Large Unsorted Model", ViewType.SIMPLE_LARGE_MODEL));
            listbox.add (make_viewtype_button ("Very Large Unsorted Model", ViewType.SIMPLE_VERY_LARGE_MODEL));
            listbox.add (make_viewtype_button ("Large Sorted Model", ViewType.SORTED_LARGE_MODEL));
            listbox.add (make_viewtype_button ("Very Large Sorted Model", ViewType.SORTED_VERY_LARGE_MODEL));

            popover.add (listbox);
            popover.show_all ();
            popover.hide ();

            set_popover (popover);
        }

        public AppMenu () {
            Object (
                image: new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR),
                tooltip_text: "Options"
            );
        }

        private void handle_button (ViewType type) {
            popover.hide ();
            change_view (type);
        }

        private Gtk.Button make_viewtype_button (string label, ViewType type) {
            var button = new Gtk.Button.with_label (label);
            button.clicked.connect (() => {
                handle_button (type);
            });

            return button;
        }
    }
}

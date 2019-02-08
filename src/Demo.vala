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

enum ViewType {
    SIMPLE,
    SIMPLE_SORTED
}

public class App : Gtk.Application {
    construct {
        application_id = "com.github.jeremypw.widget-grid-demo";
    }

    public override void startup () {
        base.startup ();
    }


    public override void activate () {
       this.add_window (new DemoWindow ());
    }
}

public class DemoWindow : Gtk.ApplicationWindow {
    private GOF.Directory.Async dir;
    private TopMenu top_menu;
    private View view;

    construct {
        var app_menu = new AppMenu ();

        app_menu.change_view.connect (change_view);

        top_menu = new TopMenu (app_menu);

        view = make_simple_view ();
        view.item_width = 64;
        populate_view (view);

        set_titlebar (top_menu);
        add (view);

        set_default_size (800, 600);
        resizable = true;

        show_all ();
    }

    private void populate_view (View view) {
        GLib.File dirfile;
        int n = 1;
        /* This adds about 128 * n icon items to the view */
        for (int i = 0; i < n; i++) {
            dirfile = GLib.File.new_for_commandline_arg ("/usr/share/applications");

            dir = GOF.Directory.Async.from_gfile (dirfile);

            dir.file_loaded.connect ((file) => {
                file.update_icon (view.item_width, 1);
                var data = new DemoItemData (file);
                view.add_data (data);

            });


            dir.init ();
        }
    }

    private View make_simple_view () {
        return new View (new DemoItemFactory (),
                             new SimpleModel ());
    }

    private View make_simple_sorted_view () {
        return new View (new DemoItemFactory (),
                             new SimpleSortedListModel ());
    }

    private void change_view (ViewType type) {
        var width = view.item_width;
        view.destroy ();
        var subtitle = "Simple Unsorted View";
        switch (type) {
            case ViewType.SIMPLE_SORTED:
                view = make_simple_sorted_view ();
                subtitle = "Simple Sorted View";
                break;

            default:
                view = make_simple_view ();
                break;
        }

        view.item_width = width;
        populate_view (view);
        view.show_all ();
        add (view);

        top_menu.set_title ("WidgetGrid Demo");
        top_menu.set_subtitle (subtitle);
    }

    private class TopMenu : Gtk.HeaderBar {
        public Gtk.MenuButton menu { get; construct; }

        construct {
            pack_end (menu);
        }

        public TopMenu (AppMenu menu) {
            Object (menu: menu,
                    show_close_button: true);
        }
    }

    private class AppMenu : Gtk.MenuButton {
        public signal void change_view (ViewType type);

        construct {
            var popover = new Gtk.Popover (this);
            var listbox = new Gtk.ListBox ();
            var simple_button = new Gtk.Button.with_label ("Simple Unsorted View");
            simple_button.xalign = 0.0f;
            simple_button.clicked.connect (() => {
                handle_button (ViewType.SIMPLE);
            });

            listbox.add (simple_button);

            var simple_sorted_button = new Gtk.Button.with_label ("Simple Sorted View");
            simple_sorted_button.xalign = 0.0f;
            simple_sorted_button.clicked.connect (() => {
                handle_button (ViewType.SIMPLE_SORTED);
            });

            listbox.add (simple_sorted_button);

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
    }
}
}

public static int main (string[] args) {
    var app = new WidgetGrid.App ();
    return app.run (args);
}


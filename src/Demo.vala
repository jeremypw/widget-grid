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
    SIMPLE_LARGE_MODEL,
    SIMPLE_VERY_LARGE_MODEL,
    SIMPLE_SORTED,
    SORTED_LARGE_MODEL,
    SORTED_VERY_LARGE_MODEL
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
    private TopMenu top_menu;
    private View view;
    GOF.Directory.Async dir;

    construct {
        var app_menu = new AppMenu ();
        top_menu = new TopMenu (app_menu);
        set_titlebar (top_menu);
        set_default_size (800, 600);
        resizable = true;

        change_view (ViewType.SIMPLE);

        show_all ();

        app_menu.change_view.connect (change_view);

    }

    private void populate_view (View view, int copies) {
        GLib.File dirfile;
        /* This adds about 128 * n icon items to the view */
        dirfile = GLib.File.new_for_commandline_arg ("/usr/share/applications");
        dir = GOF.Directory.Async.from_gfile (dirfile);
        n_copies = copies;
        dir.done_loading.connect (on_done_loading);
        dir.file_loaded.connect (on_file_loaded);
        dir.init ();
    }

    private void on_file_loaded (GOF.File file) {
        file.update_icon (view.item_width, 1);
        var data = new DemoItemData (file);
        view.add_data (data);
    }

    private int load_count = 0;
    private int n_copies = 1;
    private void on_done_loading () {
        load_count++;
        if (load_count < n_copies) {
            dir.init ();
            return;
        } else {
            view.sort ((CompareDataFunc?)(WidgetData.compare_data_func));
            top_menu.subtitle = top_menu.subtitle + " - %i items".printf (view.n_items);
            dir.done_loading.disconnect (on_done_loading);
            dir.file_loaded.disconnect (on_file_loaded);
        }
    }

    private View make_simple_view () {
        return new View (new DemoItemFactory (),
                             new SimpleModel ());
    }

    private View make_simple_sorted_view () {
        return new View (new DemoItemFactory (),
                             new SimpleSortableListModel ());
    }

    private void change_view (ViewType type) {
        int width;

        if (view != null) {
            width = view.item_width;
            remove (view);
            view.destroy ();
        } else {
            width = 64;
        }

        var subtitle = "Simple Unsorted View";
        int copies = 1;
        switch (type) {
            case ViewType.SIMPLE_SORTED:
                view = make_simple_sorted_view ();
                subtitle = "Simple Sorted View";
                break;
            case ViewType.SIMPLE_LARGE_MODEL:
                view = make_simple_view ();
                subtitle = "Simple Unsorted View with 10,000 items";
                copies = 100;
                break;
            case ViewType.SIMPLE_VERY_LARGE_MODEL:
                view = make_simple_view ();
                subtitle = "Simple Unsorted View with 100,000 items";
                copies = 1000;
                break;
            case ViewType.SORTED_LARGE_MODEL:
                view = make_simple_sorted_view ();
                subtitle = "Simple Sorted View with 10,000 items";
                copies = 100;
                break;
            case ViewType.SORTED_VERY_LARGE_MODEL:
                view = make_simple_sorted_view ();
                subtitle = "Simple Sorted View with 100,000 items";
                copies = 1000;
                break;

            default:
                view = make_simple_view ();
                break;
        }

        top_menu.set_title ("WidgetGrid Demo");
        top_menu.set_subtitle (subtitle);

        view.item_width = width;
        populate_view (view, copies);
        view.show_all ();
        add (view);
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
            button.xalign = 0.0f;
            button.clicked.connect (() => {
                handle_button (type);
            });

            return button;
        }
    }
}
}

public static int main (string[] args) {
    var app = new WidgetGrid.App ();
    return app.run (args);
}


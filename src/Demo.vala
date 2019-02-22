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

/*** A demo app to show basic abilities of the WidgetGrid.View (i.e. efficient reflow,
     zooming, rubberband selection).  It gives an example of a widget using the pantheon-files-core
     library to give a file-manager like view.  It also demonstrates providing an alternative
     Model that is sortable to use with the View.  IT is possible to choose the size of the model
     to show that there is little difference in speed of View facilities even with large models.
***/
namespace WidgetGridDemo {
public enum ViewType {
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
    private Gtk.HeaderBar top_menu;
    private WidgetGrid.View view;
    private WidgetGrid.Model<WidgetGrid.DataInterface> model;
    GOF.Directory.Async dir;

    public string view_path { get; construct; }

    construct {
        view_path = "/usr/share/applications";
        var app_menu = new AppMenu ();
        top_menu = new Gtk.HeaderBar ();
        top_menu.pack_end (app_menu);
        top_menu.show_close_button = true;

        set_titlebar (top_menu);
        set_default_size (800, 600);
        resizable = true;

        change_view (ViewType.SIMPLE);

        realize.connect (() => {
            populate_view ();
        });

        app_menu.change_view.connect ((type) => {
            change_view (type);
            populate_view ();
        });

        show_all ();
    }

    int copies = 1;
    private void populate_view () {
        GLib.File dirfile;
        /* This adds about 128 * n icon items to the view */
        dirfile = GLib.File.new_for_commandline_arg (view_path);
        dir = GOF.Directory.Async.from_gfile (dirfile);
        n_copies = copies;
        dir.done_loading.connect (on_done_loading);
        dir.file_loaded.connect (on_file_loaded);
        dir.init ();
    }

    private void on_file_loaded (GOF.File file) {
        file.update_icon (view.item_width, 1);
        var data = new DemoItemData (file);
        model.add (data);
    }

    private int load_count = 0;
    private int n_copies = 1;
    private void on_done_loading () {
        load_count++;
        if (load_count < n_copies) {
            dir.init ();
            return;
        } else {
            view.sort ((CompareDataFunc?)(WidgetGrid.DataInterface.compare_data_func));
            top_menu.subtitle = top_menu.subtitle + " - %i items".printf (model.get_n_items ());
            dir.done_loading.disconnect (on_done_loading);
            dir.file_loaded.disconnect (on_file_loaded);
        }
    }

    private WidgetGrid.View make_simple_view () {
        model = new WidgetGrid.SimpleModel ();
        return new WidgetGrid.View (new IconGridItemFactory (), model);
    }

    private WidgetGrid.View make_simple_sorted_view () {
        model = new SimpleSortableListModel ();
        return new WidgetGrid.View (new IconGridItemFactory (), model);
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
        copies = 1;
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

        view.item_clicked.connect (on_view_item_clicked);
        view.background_clicked.connect (on_view_background_clicked);
        view.item_width = width;
        view.show_all ();
        add (view);
    }

    private void on_view_item_clicked (WidgetGrid.Item item, Gdk.EventButton event) {
        switch (event.button) {
            case Gdk.BUTTON_PRIMARY:
                item.button_press_event (event);
                break;

            case Gdk.BUTTON_SECONDARY:
                show_item_context_menu (item, view.get_selected ());
                break;

            default:
                break;
        }
    }

    private void on_view_background_clicked (Gdk.EventButton event) {
        if (event.button == Gdk.BUTTON_SECONDARY) {
            show_background_context_menu_at ((int)(event.x), (int)(event.y));
        }
    }

    private void show_item_context_menu (WidgetGrid.Item item, WidgetGrid.DataInterface[] selected) {
        var popover = new Gtk.Popover (item);

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.margin = 12;
        grid.add (new FilePropertiesGrid (((IconGridItem)(item)).file));

        var button = new Gtk.Button.with_label ("Close Item Context Menu");
        button.margin = 12;
        button.halign = Gtk.Align.END;
        button.hexpand = false;
        button.clicked.connect (() => {popover.popdown ();});

        grid.add (button);

        popover.add (grid);
        popover.show_all ();
        popover.popup ();
    }

    private void show_background_context_menu_at (int x, int y) {
        var popover = new Gtk.Popover (view);
        var rect = Gdk.Rectangle () {x = x, y = y, width = 1, height = 1};
        popover.set_pointing_to (rect);

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.hexpand = true;
        grid.margin = 12;

        var property_grid = new ViewPropertiesGrid (view_path, view);
        property_grid.hpadding_changed.connect ((new_hpad) => {
            view.hpadding = new_hpad;
        });

        property_grid.vpadding_changed.connect ((new_vpad) => {
            view.vpadding = new_vpad;
        });

        grid.add (property_grid);

        var button = new Gtk.Button.with_label ("Close Item Context Menu");
        button.margin = 12;
        button.halign = Gtk.Align.END;
        button.hexpand = false;
        button.clicked.connect (() => {popover.popdown ();});

        grid.add (button);

        popover.add (grid);
        popover.show_all ();
        popover.popup ();
    }
}
}

public static int main (string[] args) {
    var app = new WidgetGridDemo.App ();
    return app.run (args);
}


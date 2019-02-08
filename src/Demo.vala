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
    public Gtk.Layout layout;
    private GOF.Directory.Async dir;

    construct {
        var view = new View (new DemoItemFactory ());
        Gtk.IconTheme theme;
        GLib.File dirfile;

        view.item_width = 64;
        int n = 1;

        /* This adds about 128 * n icon items to the view */
        for (int i = 0; i < n; i++) {
            try {
                dirfile = GLib.File.new_for_commandline_arg ("/usr/share/applications");
            } catch (Error e) {
                warning ("Did not load app dir - %s", e.message);
            }

            dir = GOF.Directory.Async.from_gfile (dirfile);

            dir.file_loaded.connect ((file) => {
                file.update_icon (view.item_width, 1);
                var data = new DemoItemData (file);
                view.add_data (data);

            });


            dir.init ();
        }

        add (view);

        set_default_size (800, 600);
        resizable = true;

        show_all ();
    }
}
}

public static int main (string[] args) {
    var app = new WidgetGrid.App ();
    return app.run (args);
}


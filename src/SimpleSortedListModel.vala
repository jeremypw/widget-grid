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

/*** A demo WidgetGrid.Model which is sortable.
***/
namespace WidgetGridDemo {
public class SimpleSortableListModel : Object, WidgetGrid.Model {
    private Gee.LinkedList<WidgetGrid.DataInterface> list;

    construct {
        list = new Gee.LinkedList<WidgetGrid.DataInterface> ();
    }

    public bool add (WidgetGrid.DataInterface data) {
        var res = list.add (data);
        if (res) {
            n_items_changed (1);
        }

        return res;
    }

    public bool sort (CompareDataFunc func) {
        /* Use closure just to avoid warning re copying delegates */
        list.sort ((a, b) => {
            return func (a, b);
        });

        return true;
    }

    public bool remove_data (WidgetGrid.DataInterface data) {
        var res = list.remove (data);
        if (res) {
            n_items_changed (-1);
        }

        return res;
    }

    public bool remove_index (int index) {
        var res = list.remove_at (index) != null;
        if (res) {
            n_items_changed (-1);
        }

        return res;
    }

    public WidgetGrid.DataInterface? lookup_index (int index) {
        return (WidgetGrid.DataInterface?)(list.@get (index));
    }

    public int lookup_data (WidgetGrid.DataInterface data) {
        return list.index_of (data);
    }

    public int get_n_items () {
        return list.size;
    }
}
}

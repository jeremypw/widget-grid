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

public class SimpleSortedListModel : Object, Model<WidgetData> {
    private ListStore list;

    construct {
        list = new ListStore (typeof (WidgetData));
    }

    public bool add (WidgetData data) {
        list.insert_sorted (data, ((CompareDataFunc?)(WidgetData.compare_data_func)));

        return true;
    }

    public bool remove_data (WidgetData data) {
        /* No fast native way to do this */
        var pos = find_data (data);
        if (pos > -1) {
            list.remove (pos);
            return true;
        } else {
            return false;
        }
    }

    public void remove_index (int index) {
        list.remove (index);
    }

    public WidgetData lookup_index (int index) {
        return (WidgetData)(list.get_item (index));
    }

    public int lookup_data (WidgetData data) {
        return find_data (data);
    }

    private int find_data (WidgetData data) {
        int result = -1;
        int index;
        WidgetData? dat = null;
        var n_items = list.get_n_items ();
        for (index = 0; index < n_items; index++) {
            dat = lookup_index (index);
            if (dat == null || dat.equal (data)) {
                break;
            }
        }

        if (dat.equal (data)) {
            list.remove (index);
            result = index;
        }

        return result;
    }
}
}

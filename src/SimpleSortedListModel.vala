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

public class SimpleSortableListModel : Object, Model<WidgetData> {
    private Gee.LinkedList<WidgetData> list;

    construct {
        list = new Gee.LinkedList<WidgetData> ();
    }

    public bool add (WidgetData data) {
        return list.add (data);
    }

    public bool sort (CompareDataFunc? func) {
        list.sort (func);
        return true;
    }

    public bool remove_data (WidgetData data) {
        return list.remove (data);
    }

    public bool remove_index (int index) {
        return list.remove_at (index) != null;
    }

    public WidgetData lookup_index (int index) {
        return (WidgetData)(list.@get (index));
    }

    public int lookup_data (WidgetData data) {
        return list.index_of (data);
    }
}
}

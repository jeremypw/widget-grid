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

[GenericAccessors]
public interface Model<G> : Object {
    public abstract bool add (G data); /* Returns position inserted at (or -1 if not implemented) */
    public virtual int add_array (G[] data_array) { /* Returns positions inserted at */
        int added = 0;
        var n_items = data_array.length;
        for (int index = 0; index < n_items; index++) {
            if (add (data_array[index])) {
                added++;
            }
        }

        return added;
    }

    public abstract bool remove_index (int index);
    public abstract bool remove_data (G data);

    public abstract G lookup_index (int index);
    public abstract int lookup_data (G data);

    public virtual bool sort (CompareDataFunc? func) {
        return false;
    }
}
}

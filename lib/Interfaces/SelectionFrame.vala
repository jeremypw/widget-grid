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

public interface SelectionFrame : Object {
    public abstract int x { get; set; }
    public abstract int y { get; set; }
    public abstract int width { get; set; }
    public abstract int height { get; set; }

    public abstract void initialize (int x, int y);
    public abstract void update (int x, int y, int width, int height);
    public abstract void close ();
    public abstract bool draw (Cairo.Context ctx);
}

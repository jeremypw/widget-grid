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

/*** A wrapper that makes a GOF.File object suitable as WidgetData for WidgetGrid.View
***/
namespace WidgetGridDemo {
public class DemoItemData : WidgetGrid.WidgetData {
    public static int start_number = 0;
    public GOF.File file { get; construct; }
    public int data_number;

    public DemoItemData (GOF.File file) {
        Object (file: file);
        data_number = DemoItemData.start_number++;
    }
}
}

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

namespace WidgetGridDemo {
public class FilePropertiesGrid : Gtk.Grid {
    public GOF.File file { get; construct; }

    construct {
        var name_klabel = new KeyLabel ("Name");
        var name_vlabel = new ValueLabel (file.get_display_name ());

        var uri_klabel = new KeyLabel ("Uri");
        var uri_vlabel = new ValueLabel (file.uri);

        var type_klabel = new KeyLabel ("Type");
        var type_vlabel = new ValueLabel (file.formated_type);

        var ftype = file.get_ftype ();
        var mimetype_klabel = new KeyLabel ("MIME type:");
        var mimetype_vlabel = new ValueLabel (ftype);

        var time_created = PF.FileUtils.get_formatted_time_attribute_from_info (file.info,
                                                                                FileAttribute.TIME_CREATED);

        var created_klabel = new KeyLabel ("Created");
        var created_vlabel = new ValueLabel (time_created);

        var time_modified = PF.FileUtils.get_formatted_time_attribute_from_info (file.info,
                                                                                 FileAttribute.TIME_MODIFIED);
        var modified_klabel = new KeyLabel ("Modified:");
        var modified_vlabel = new ValueLabel (time_modified);


        var size_klabel = new KeyLabel ("Size");
        var size_vlabel = new ValueLabel (file.format_size);

        attach (name_klabel, 0, 0, 1, 1);
        attach_next_to (name_vlabel, name_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (uri_klabel, 0, 1, 1, 1);
        attach_next_to (uri_vlabel, uri_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (type_klabel, 0, 2, 1, 1);
        attach_next_to (type_vlabel, type_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (mimetype_klabel, 0, 3, 1, 1);
        attach_next_to (mimetype_vlabel, mimetype_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (created_klabel, 0, 4, 1, 1);
        attach_next_to (created_vlabel, created_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (modified_klabel, 0, 5, 1, 1);
        attach_next_to (modified_vlabel, modified_klabel, Gtk.PositionType.RIGHT, 1, 1);
        attach (size_klabel, 0, 6, 1, 1);
        attach_next_to (size_vlabel, size_klabel, Gtk.PositionType.RIGHT, 1, 1);

        show_all ();
    }

    public FilePropertiesGrid (GOF.File file) {
        Object (file: file);
    }
}
}

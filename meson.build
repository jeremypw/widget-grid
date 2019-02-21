project ('com.github.jeremypw.widget-grid', 'vala', 'c')
libname = 'widget-grid'
domain = 'com.github.jeremypw.'
libver = '0.1'

meson.get_compiler('c').find_library('pantheon-files-core')

valac = find_program ('valac')
libvala_version = run_command(valac, '--api-version').stdout().strip()
libvala_dep = dependency('libvala-@0@'.format(libvala_version))
gtk_dep = dependency('gtk+-3.0', version: '>=3.22', required: true)
gee_dep = dependency('gee-0.8')
granite_dep = dependency('granite', version: '>=5.2.0')
pantheon_files_core_dep = dependency ('pantheon-files-core')

subdir ('libwidgetgrid')

demo_deps = [gtk_dep, granite_dep, gee_dep, pantheon_files_core_dep, widgetgrid_dep]

#lib = shared_library (
#    libname,
#    'lib/Interfaces/SelectionHandler.vala',
#    'lib/Interfaces/SelectionFrame.vala',
#    'lib/Interfaces/PositionHandler.vala',
#    'lib/Interfaces/Item.vala',
#    'lib/Interfaces/Model.vala',
#    'lib/View.vala',
#    'lib/AbstractItemFactory.vala',
#    'lib/WidgetData.vala',
#    'lib/SimpleModel.vala',
#    'lib/LayoutHandler.vala',
#    'lib/SelectionFrameRectangle.vala',
#    'lib/RowData.vala',

#    dependencies : [
#        gtk_dep,
#        libvala_dep,
#        dependency ('granite'),
#    ],

#    install: true,
#    install_dir: [true, true, true],
#    version: libver,
#    soversion: '0'
#)

#pkg = import ('pkgconfig')
#pkg.generate (
#    description: 'High performance icon view',
#    filebase: 'widget-grid',
#    libraries: lib,
#    name: libname,
#    version: libver,
#    requires: ['gtk+-3.0', 'valac', 'gee-0.8']
#)



executable (
    'widget-grid-demo',
    'src/Demo.vala',
    'src/DemoItemData.vala',
    'src/DemoItemFactory.vala',
    'src/SimpleSortedListModel.vala',
    'src/AppMenu.vala',
    'src/FilePropertiesGrid.vala',
    'src/ViewPropertiesGrid.vala',
    'src/PropertiesWidgets.vala',

    dependencies : [
        demo_deps
    ],

    link_with: widgetgrid_lib,
    install: true,
)


project ('com.github.jeremypw.widget-grid', 'vala', 'c')
libname = 'widget-grid'
domain = 'com.github.jeremypw.'
libver = '0.1'

meson.get_compiler('c').find_library('pantheon-files-core')

gtk_dep = dependency('gtk+-3.0', version: '>=3.22', required: true)
gee_dep = dependency('gee-0.8')
granite_dep = dependency('granite', version: '>=5.2.0')
pantheon_files_core_dep = dependency ('pantheon-files-core')

subdir ('libwidgetgrid')

demo_deps = [gtk_dep, granite_dep, gee_dep, pantheon_files_core_dep, widgetgrid_dep]

executable (
    'widget-grid-demo',
    'src/Demo.vala',
    'src/DemoItemData.vala',
    'src/IconGridItem.vala',
    'src/IconGridItemFactory.vala',
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


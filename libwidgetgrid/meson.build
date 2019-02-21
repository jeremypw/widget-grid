libname = 'libwidgetgrid'
libver = '0.1'

#valac = find_program ('valac')
#libvala_version = run_command(valac, '--api-version').stdout().strip()
#libvala_dep = dependency('libvala-@0@'.format(libvala_version))

#gee_dep = dependency('gee-0.8')
#gtk_dep = dependency('gtk+-3.0', version: '>=3.22')

libwidgetgrid_deps = [
    libvala_dep,
    gtk_dep,
    gee_dep
]

widgetgrid_lib = shared_library (
    libname,
    'Interfaces/SelectionHandler.vala',
    'Interfaces/SelectionFrame.vala',
    'Interfaces/PositionHandler.vala',
    'Interfaces/Item.vala',
    'Interfaces/Model.vala',
    'View.vala',
    'AbstractItemFactory.vala',
    'WidgetData.vala',
    'SimpleModel.vala',
    'LayoutHandler.vala',
    'SelectionFrameRectangle.vala',
    'RowData.vala',

    dependencies : [
        libwidgetgrid_deps
    ],

    install: false,
    version: libver,
    soversion: '0'
)

widgetgrid_dep = declare_dependency(
    link_with: widgetgrid_lib,
    include_directories: include_directories('.'),
    dependencies : [ libwidgetgrid_deps ],
)

pkg = import ('pkgconfig')
pkg.generate (
    description: 'High performance grid view for large amounts of data',
    filebase: libname,
    libraries: libname,
    name: libname,
    version: libver,
    requires: ['gtk+-3.0', 'valac', 'gee-0.8']
)
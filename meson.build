project ('com.github.jeremypw.widget-grid', 'vala', 'c')
libname = 'widget-grid'
domain = 'com.github.jeremypw.'
libver = '0.1'

meson.get_compiler('c').find_library('pantheon-files-core')

valac = find_program ('valac')
libvala_version = run_command(valac, '--api-version').stdout().strip()
libvala_dep = dependency('libvala-@0@'.format(libvala_version))

dependency('gtk+-3.0', version: '>=3.22', required: true)

lib = shared_library (
    libname,
    'lib/View.vala',
    'lib/AbstractItemFactory.vala',
    'lib/AbstractData.vala',
    'lib/ItemInterface.vala',
    'lib/ModelInterface.vala',
    'lib/SimpleModel.vala',

    dependencies : [
        dependency ('gtk+-3.0'),
        libvala_dep,
        dependency ('granite'),
    ],

    install: true,
    install_dir: [true, true, true],
    version: libver,
    soversion: '0'
)

pkg = import ('pkgconfig')
pkg.generate (
    description: 'High performance icon view',
    filebase: 'widget-grid',
    libraries: lib,
    name: libname,
    version: libver,
    requires: ['gtk+-3.0', 'valac', 'granite']
)

executable (
    'widget-grid-demo',
    'src/Demo.vala',
    'src/DemoItemData.vala',
    'src/DemoItemFactory.vala',
    'src/SimpleSortedListModel.vala',

    dependencies : [
        dependency ('gtk+-3.0'),
        dependency ('granite'),
        dependency('gee-0.8'),
        libvala_dep,
        dependency ('pantheon-files-core')
    ],

    install: true,
    link_with: [lib]
)


project('n_flasher', ['c', 'd'], version: '0.0.1')

gnome = import('gnome')

n_flasher_sources = [
    'source/app.d',
    'source/Defines.d',
    'source/LogViewer.d',
    'source/NFlasherWin.d',
    'source/PhoneFlasher.d'
]

source_root = meson.source_root()
sources_dir = include_directories('source/')

resources_dir = 'resource/'

gtkd_dep = dependency('gtkd-3')
gtk_dep = dependency('gtk+-3.0')

djtext_dep = dependency('djtext', method : 'dub')

n_flasher_resources = gnome.compile_resources('n_flasher_resources',
    files('resource/n_flasher.gresource.xml'),
    source_dir : [resources_dir],
    c_name: 'n_flasher')

n_flasher_bin = executable('n_flasher',
    [n_flasher_sources, n_flasher_resources],
    include_directories : [sources_dir],
    dependencies : [gtkd_dep, gtk_dep, djtext_dep])
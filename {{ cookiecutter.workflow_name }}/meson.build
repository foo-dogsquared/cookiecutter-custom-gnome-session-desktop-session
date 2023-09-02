project('{{ cookiecutter.workflow_name }}',
  version: '{% now 'utc', '%F' %}',
  license: 'GPL-3.0-or-later',
  meson_version: '>=0.54.0',
)

app_id = '{{ cookiecutter.workflow_prefix }}'
prefix = get_option('prefix')
libexecdir = join_paths(prefix, get_option('libexecdir'))
datadir = join_paths(prefix, get_option('datadir'))
systemddir = join_paths(datadir, 'systemd')
applicationsdir = join_paths(datadir, 'applications')
systemduserdir = join_paths(systemddir, 'user')
autostartdir = join_paths(prefix, 'etc', 'xdg', 'autostart')
unit_name_template = app_id + '.@0@.@1@'

required_components = { }

session_dropins = [
  'gnome-session@{{ cookiecutter.workflow_name }}.target.d',
]

session_wants = ''
foreach name, component : required_components
  session_wants += 'Wants=' + unit_name_template.format(name, 'target') + '\n'
endforeach

# Install each gnome-session overrides.
sessionconf = configuration_data()
sessionconf.set('session_wants', session_wants)
foreach session_dropin : session_dropins
  configure_file(
    input: '{{ cookiecutter.workflow_name }}.systemd-conf.in',
    output: 'session.conf',
    install_dir: join_paths(systemduserdir, session_dropin),
    configuration: sessionconf,
    install: true
  )
endforeach

# Installing the Wayland session desktop entry.
desktopentryconf = configuration_data()
desktopentryconf.set('libexecdir', libexecdir)
configure_file(
  input: '{{ cookiecutter.workflow_name }}.desktop',
  output: '{{ cookiecutter.workflow_name }}.desktop',
  install_dir: join_paths(datadir, 'wayland-sessions'),
  configuration: desktopentryconf,
  install: true,
)

# Installing the core systemd units for the desktop session. This is both for
# the systemd- and non-systemd-managed GNOME sessions.
targetconf = configuration_data()
targetconf.set('app_id', app_id)
configure_file(
  input: '{{ cookiecutter.workflow_name }}.target',
  output: app_id + '.target',
  install_dir: systemduserdir,
  configuration: targetconf,
  install: true,
)

serviceconf = configuration_data()
serviceconf.set('script', get_option('service_script'))
configure_file(
  input: '{{ cookiecutter.workflow_name }}.service',
  output: app_id + '.service',
  install_dir: systemduserdir,
  configuration: serviceconf,
  install: true,
)

configure_file(
  input: '{{ cookiecutter.workflow_name }}.desktop.in',
  output: app_id + '.desktop',
  install_dir: applicationsdir,
  configuration: serviceconf,
  install: true,
)

# Setting up for installing with the core services systemd units.
required_services = []
foreach name, component : required_components
  required_services += app_id + '.' + name
endforeach

gnomesessionconf = configuration_data()
gnomesessionconf.set(
  'required_components',
  ';'.join([ app_id ] + required_services) + ';'
)
configure_file(
  input: '{{ cookiecutter.workflow_name }}.gnome-session.in',
  output: '{{ cookiecutter.workflow_name }}.session',
  install_dir: datadir / 'gnome-session/sessions',
  configuration: gnomesessionconf,
  install: true,
)

runconf = configuration_data()
runconf.set('prefix', prefix)
configure_file(
  input: '{{ cookiecutter.workflow_name }}.bin.in',
  output: '{{ cookiecutter.workflow_name }}-session',
  install_dir: libexecdir,
  configuration: runconf,
  install: true,
)

foreach name, component : required_components
  componentsconf = configuration_data()
  componentsconf.set('component', name)
  componentsconf.set('app_id', app_id)
  componentsconf.set('description', component.get('description'))
  componentsconf.set('script', component.get('script'))
  componentsconf.set('gsm_phase', component.get('gsm_phase', 'Desktop'))

  configure_file(
    input: 'core-service.service.in',
    output: unit_name_template.format(name, 'service'),
    install_dir: systemduserdir,
    configuration: componentsconf,
    install: true,
  )

  configure_file(
    input: 'core-service.target.in',
    output: unit_name_template.format(name, 'target'),
    install_dir: systemduserdir,
    configuration: componentsconf,
    install: true,
  )

  configure_file(
    input: 'core-service.desktop.in',
    output: unit_name_template.format(name, 'desktop'),
    install_dir: autostartdir,
    configuration: componentsconf,
    install: true,
  )
endforeach

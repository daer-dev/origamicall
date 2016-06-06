class locale (
  $locales = 'es_ES.UTF-8',
  $charset = 'UTF-8'
) {
  package { 'locales':
    ensure => 'present',
    require => Exec['apt_update']
  }

  Exec {
    path => [ '/usr/bin', '/usr/sbin', '/bin' ]
  }

  file { '/etc/locale.gen':
    ensure => present,
    mode => '0644',
    owner => 'root',
    content => "${locales} ${charset}",
    require => Package['locales']
  }

  exec { 'install_locales':
    command => "locale-gen",
    refreshonly => true,
    subscribe => File['/etc/locale.gen'],
    notify => Exec['reload_locales'],
    require => Package['locales']
  }

  exec { 'reload_locales':
    command => "dpkg-reconfigure locales",
    refreshonly => true,
    require => Package['locales']
  }
}
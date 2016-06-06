define origamicall::webo(
  $dev_stuff = true,
  $webo_path = '/srv',
) {
  file { '/etc/profile.d/append-ruby-path.sh':
    mode => 644,
    content => 'export PATH=/opt/ruby-2.1/bin:$PATH'
  }

  package { 'ruby-2.1':
    ensure => 'latest',
    require => Apt::Source['foobar']
  }

  file { '/usr/bin/gem':
    ensure => 'link',
    target => '/opt/ruby-2.1/bin/gem',
    require => Package['ruby-2.1']
  }

  if $dev_stuff {
    package { 'mailcatcher':
      provider => 'gem',
      ensure => 'present',
      source => 'http://rubygems.org/',
      require => [
        Package['ruby-2.1'],
        File['/usr/bin/gem'],
        Package['build-essential'],
        Package['libsqlite3-dev']
      ]
    }
  } else {
    package { 'postfix':
      ensure =>  'present',
      require => Exec['apt_update']
    }
  }

  package { 'bundle':
    provider => 'gem',
    ensure => 'present',
    source => 'http://rubygems.org/',
    require => [
      Package['ruby-2.1'],
      File['/usr/bin/gem']
    ]
  }

  exec { 'rails':
    command => 'bundle install',
    path => '/usr/bin:/bin:/opt/ruby-2.1/bin',
    cwd => $webo_path,
    user => 'vagrant',
    require => Package['bundle']
  }

  package { 'beanstalkd':
    ensure => 'present',
    require => Exec['apt_update']
  }
}

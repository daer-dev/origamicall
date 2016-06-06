define origamicall::apt {
  class { 'apt':
    always_apt_update => true
  }

  apt::key { 'foobar':
    ensure => 'present',
    key => 'ABCD1234',
    key_source => 'http://apt.foobar.com/foobar.key'
  }

  apt::source { 'foobar':
    location => 'http://apt.foobar.com',
    release => 'wheezy',
    repos => 'contrib',
    include_src => true,
    require => [
      Apt::Key['foobar'],
    ]
  }
}

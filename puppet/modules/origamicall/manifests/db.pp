define origamicall::db(
  $sql_path = '/srv/puppet/files'
) {
  class { 'postgresql::server':
    #ip_mask_allow_all_users => '10.0.2.0/24',
    listen_addresses => '*',
    ipv4acls => [
      'host all all 10.0.2.0/24 md5',   # vagrant
      'host all all 172.17.0.0/24 md5', # docker
      'host all all 127.0.0.1/32 md5',
    ],
    require => Exec['apt_update']
  }

  package { 'postgresql-contrib':
    ensure => 'present',
    require => Exec['apt_update']
  }

  exec { 'ltree':
    path => '/usr/bin:/bin',
    user => 'postgres',
    cwd => $sql_path,
    command => 'psql dbcore < ltree.sql',
    require => Postgresql::Server::Db['dbcore']
  }

  postgresql::server::db { 'dbcore':
    user => 'origami',
    password => 'origamicall2015',
    grant => 'all',
    require => Class['postgresql::server']
  }
}

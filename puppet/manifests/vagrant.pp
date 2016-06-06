
origamicall::apt { 'origamicall': }

origamicall::base { 'origamicall': }

origamicall::db { 'origamicall':
  sql_path => '/vagrant/puppet/files'
}

origamicall::webo { 'origamicall':
  dev_stuff => true,
  webo_path => '/vagrant'
}

origamicall::apt { 'origamicall': }

origamicall::base { 'origamicall': }

origamicall::db { 'origamicall':
  sql_path => '/srv/webo/puppet/files'
}

origamicall::webo { 'origamicall':
  dev_stuff => false,
  webo_path => '/srv/webo'
}
#!/bin/bash

RUBY_BIN="/opt/ruby-2.1/bin"

cd $(dirname $0)/..

while true; do
  puppet apply /srv/webo/puppet/manifests/docker.pp --modulepath=/srv/webo/puppet/modules

  service postfix start

  $RUBY_BIN/bundle install

  export SECRET_KEY_BASE=$($RUBY_BIN/rake secret)

  $RUBY_BIN/rake db:migrate
  $RUBY_BIN/rake db:seed
  $RUBY_BIN/rake tmp:clear
  $RUBY_BIN/rake assets:precompile RAILS_ENV=production
  $RUBY_BIN/rails server -e production -p 3000 -b 0.0.0.0 -d

  bash
done
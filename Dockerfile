FROM foobar/debian-puppet
MAINTAINER Daniel Herrero <daniel.herrero.101@gmail.com>

VOLUME [ "/srv/webo" ]

WORKDIR /srv/webo
ADD puppet /srv/webo/puppet
ADD Gemfile /srv/webo/Gemfile

RUN [ "puppet", "apply", "/srv/webo/puppet/manifests/docker.pp", "--modulepath=/srv/webo/puppet/modules" ]

CMD [ "bash", "/srv/webo/puppet/docker-run.sh" ]

EXPOSE 3000

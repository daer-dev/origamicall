# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'foobar/debian-7.6-puppet'

  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :forwarded_port, guest: 1080, host: 1080
  config.vm.network :forwarded_port, guest: 5432, host: 5432

  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |v, override|
    v.customize [ 'modifyvm', :id, '--natdnshostresolver1', 'on' ]
    v.customize [ 'modifyvm', :id, '--memory', 1024 ]
  end

  config.vm.synced_folder '.', '/vagrant', {
    create: true,
    :mount_options => [ 'dmode=775', 'fmode=775' ],
    owner: 'vagrant',
    group: 'vagrant'
  }

  config.vm.synced_folder '.', '/srv', {
    create: true,
    owner: 'root', group: 'root'
  }

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.manifest_file = 'vagrant.pp'
    puppet.module_path = 'puppet/modules'
    puppet.options = [ '--verbose' ]
  end
end

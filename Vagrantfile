# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # VM with Ruby 2.5.0 based on Ubuntu 14.04.5 LTS (Trusty Tahr)
  config.vm.box = "swt2/trusty-ruby25"
  config.vm.box_url = "https://github.com/hpi-swt2/swt2-vagrant/releases/download/v0.4/swt2-ruby25.box"

  # Try the following optimizations for performance.
  # Disable if problems occur or fall back to the 32bit VM
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
  end

  # port forward
  config.vm.network :forwarded_port, host: 3000, guest: 3000
  config.vm.synced_folder ".", "/home/vagrant/hpi-swt2"
end
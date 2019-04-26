# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider "virtualbox" do |vb|
    # CPUの数
    vb.cpus = 4
    # 割り当てるメモリー(MB)
    vb.memory = 1024
    # I/O APICの有効化
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # プロキシ設定
  if Vagrant.has_plugin?("vagrant-proxyconf") && ENV['PROXY_URL']
      config.proxy.http     = ENV['PROXY_URL']
      config.proxy.https    = ENV['PROXY_URL']
      config.proxy.no_proxy = "localhost,127.0.0.1"
  end
end

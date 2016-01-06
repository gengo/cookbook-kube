include_recipe 'apt'

apt_repository 'docker' do
  uri 'http://proxy.dev:3142/apt.dockerproject.org/repo'
  components %w(debian-jessie main)
  keyserver 'p80.pool.sks-keyservers.net'
  key '58118E89F3A912897C070ADBF76221572C52609D'
  cache_rebuild true
end

etcd_service 'default' do
  source 'http://proxy.dev:3142/github.com/coreos/etcd/releases/download/v2.2.3/etcd-v2.2.3-linux-amd64.tar.gz '
  version '2.2.3'
  service_manager 'systemd'
  action %w(create start)
end

flannel_service 'default' do
  action %w(create start)
end.extend FlannelCookbook::SubnetParser

docker_service 'default' do
  bip lazy { resources('flannel_service[default]').subnetfile_subnet }
  mtu lazy { resources('flannel_service[default]').subnetfile_mtu }
  install_method 'package'
  version '1.9.1'
end

remote_file 'kubectl binary' do
  path '/usr/bin/kubectl'
  mode '0755'
  source 'http://proxy.dev:3142/HTTPS///storage.googleapis.com/kubernetes-release/release/v1.1.3/bin/linux/amd64/kubectl'
  checksum '01b9bea18061a27b1cf30e34fd8ab45cfc096c9a9d57d0ed21072abb40dd3d1d'
end

kube_apiserver 'default' do
  action %w(create start)
end

group 'docker' do
  members %w(kubernetes)
end

kube_scheduler 'default' do
  action %w(create start)
end

kube_controller_manager 'default' do
  action %w(create start)
end

kubelet_service 'default' do
  action %w(create start)
end

kube_proxy 'default' do
  action %s(create)
end
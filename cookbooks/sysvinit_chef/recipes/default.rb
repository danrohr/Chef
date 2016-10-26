#
# Cookbook Name:: sysvinit_chef
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
template '/etc/init.d/chef-client' do
	source  "chef.erb"
	mode 0755
end

service 'chef-client' do
	supports status: true, restart:true
	action [:enable, :start]
end

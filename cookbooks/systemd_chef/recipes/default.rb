#
# Cookbook Name:: systemd-chef
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
template '/usr/lib/systemd/system/chef-client.service' do
	source 'chef-client.service.erb'
	mode '0644'
end

service 'chef-client' do
  action [:enable, :start]
end

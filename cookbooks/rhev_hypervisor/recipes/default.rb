#
# Cookbook Name:: motd
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
template '/etc/sysconfig/iptables' do
	source 'iptables.erb'
	mode '0644'
end

service 'iptables' do
	supports :status => true, :reload => true, :start => true
	action [ :start ]
	action :reload
end

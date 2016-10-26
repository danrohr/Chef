#
# Cookbook Name:: ntpd
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
template '/etc/ntp.conf' do
	source 'ntp.erb'
	mode '0644'
end

service 'ntpd' do
	action :stop
end

execute 'ntpdate' do 
	command 'ntpdate t42svidm2.linux.tec.org'
end

service 'ntpd' do
	supports :status => true, :restart => true
	action [ :enable, :start ]
end


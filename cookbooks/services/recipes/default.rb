#
# Cookbook Name:: services
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
service 'sshd' do
	supports :status => true
	action :start
end

service 'firewalld' do
	supports :status => true
	action :start
end

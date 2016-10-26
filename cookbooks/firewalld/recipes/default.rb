#
# Cookbook Name:: firewalld
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
firewalld_service 'sshd' do
	action :add
	zone 'default'
end

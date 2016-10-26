#
# Cookbook Name:: local_admin
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

user 'local' do
	manage_home true
	comment 'local admin'
	home '/home/local'
	shell '/bin/bash'
	password '$1$ZSsHGNbt$YzUnxHvw9U0LlY1R45l0U1'
end

group 'wheel' do 
	action :modify
	members 'local'
	append true
end

execute 'chage' do
	command '/usr/bin/chage -m 0 -M 99999 -I -1 -E -1 local'
end

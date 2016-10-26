#
# Cookbook Name:: stig_configs
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
#Take care of copying files from templates first and create needed directories
directory '/root/scripts' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end

template '/root/scripts/additional_configurations.sh' do
        source 'additional_configurations.sh'
        mode '0700'
end

template '/etc/security/pwquality.conf' do
        source 'pwquality.conf'
        mode '0644'
end

template '/etc/audit/rules.d/audit.rules' do
        source 'audit.rules'
        mode '0644'
end

template '/etc/issue' do
        source 'issue'
        mode '0644'
end

template '/etc/issue.net' do
        source 'issue'
        mode '0644'
end

template '/root/scripts/fips-kernel-mode.sh' do
	source 'fips-kernel-mode.sh'
	mode '0500'
end

template '/root/scripts/iptables.sh' do
	source 'iptables.sh'
	mode '0500'
end

template 'ipa-pam-configuration.sh' do
	source 'ipa-pam-configuration.sh' 
	mode '0500'
end

#Take care of packages installations/removals
['aide','scap-security-guide','openscap','openscap-utils'].each do |p|
        package p do
                action :install
        end
end

execute 'iwl' do
        command 'yum -y erase iwl*'
end

execute 'abrt' do
        command 'yum -y erase abrt*'
end

#Execute any actions/scripts
execute 'additional_configurations' do
	command '/root/scripts/additional_configurations.sh'
end

#Restart services that were updated
service 'ssh' do
	action :restart
end


#
# Cookbook Name:: install_nginx
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#Update catalog
execute 'Update apt-get' do
  command 'apt-get update'
end

#Install git-core
execute 'Install git' do
  command 'apt-get -y install git'
end

#Install nginx
execute 'Install nginx' do
  command 'apt-get -y install nginx'
end

#set permissions for delete (lazy way to update homepage)
execute 'change permissions' do
  command 'chmod 777 /var/www/homepage'
  ignore_failure true
  only_if do ::File.exists?('/var/www/homepage') end
end

#Delete webpage to ensure it updates (lazy way to update homepage)
execute 'delete homepage' do
  command 'rm -rf /var/www/homepage'
  ignore_failure true
  only_if do ::File.exists?('/var/www/homepage') end
end

#Get homepage
execute 'git homepage' do
  command 'git clone https://github.com/puppetlabs/exercise-webpage /var/www/homepage'
end

#set permissions for nginx default website
execute 'change permissions' do
  command 'chmod 775 /etc/nginx/sites-available/default'
  ignore_failure true
  only_if do ::File.exists?('/etc/nginx/sites-available/default') end
end

#create puppettest website
file '/etc/nginx/sites-available/default' do
  content ' server {
  listen   8000 default_server;

  access_log /var/log/nginx/puppetaccess.log;
  error_log /var/log/nginx/puppeterror.log;

  location / {

  root   /var/www/homepage/;
  index  index.html;
  }
  }'
end

#create symbolic link to puppetest site
execute 'create symbolic link' do
  command 'ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default'
  ignore_failure true
  not_if do ::File.exists?('/etc/nginx/sites-enabled/default') end
end

#enable and make sure nginx is started
service 'nginx' do
  supports :status => true
  action [:enable, :restart]
end

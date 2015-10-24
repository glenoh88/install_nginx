#
# Cookbook Name:: install_middleman
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
  command 'apt-get install nginx'
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

#create puppettest website
file '/etc/nginx/sites-available/server1.puppettest.com' do
  content 'server {

  listen   8000;
  server_name  www.puppettest.com;
  rewrite ^/(.*) http://server1.puppettest.com/$1 permanent;
  }

  server {

  listen   8000;
  server_name www.puppettest.com;

  access_log /var/www/www.puppettest/logs/access.log;
  error_log /var/www/www.puppettest/logs/error.log;

  location / {

  root   /var/www/homepage/;
  index  index.html;
  }
  }'
end

#create symbolic link to puppetest site
execute 'create symbolic link' do
  command 'ln -s /etc/nginx/sites-available/server1.puppettest.com /etc/nginx/sites-enabled/server1.puppettest.com'
  ignore_failure true
  not_if do ::File.exists?('/etc/nginx/sites-enabled/server1.puppettest.com') end
end

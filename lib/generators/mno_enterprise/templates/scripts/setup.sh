#!/bin/bash
#
# Use this script to setup upstart, monit and any server related service

# Point upstart scripts
rm -f /etc/init/<%= app_name %>*
ln -s /apps/<%= app_name %>/current/scripts/<%= environment %>/upstart/app.conf /etc/init/<%= app_name %>.conf
ln -s /apps/<%= app_name %>/current/scripts/<%= environment %>/upstart/app-web.conf /etc/init/<%= app_name %>-web.conf
ln -s /apps/<%= app_name %>/current/scripts/<%= environment %>/upstart/app-web-server.conf /etc/init/<%= app_name %>-web-server.conf
ln -s /apps/<%= app_name %>/current/scripts/<%= environment %>/upstart/app-web-hotrestart.conf /etc/init/<%= app_name %>-web-hotrestart.conf

# Reload upstart
initctl reload-configuration

# Point monit scripts
rm -f /etc/monit/conf.d/<%= app_name %>*
ln -s /apps/<%= app_name %>/current/scripts/<%= environment %>/monit/app-server.conf /etc/monit/conf.d/<%= app_name %>-server.conf

# Reload monit
service monit reload

# Nginx
rm -f /etc/nginx/sites-available/<%= app_name %>
rm -f /etc/nginx/sites-enabled/<%= app_name %>
ln -s /apps/<%= app_name %>/current/scripts/<%= environment %>/nginx/app /etc/nginx/sites-available/<%= app_name %>
ln -s /etc/nginx/sites-available/<%= app_name %> /etc/nginx/sites-enabled/<%= app_name %>
service nginx reload
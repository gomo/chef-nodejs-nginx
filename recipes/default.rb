#
# Cookbook Name:: start-nodejs
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nodejs'

node["start-nodejs"]["servers"].each do |server|
	_dir = File.dirname(server.script)
	_script = File.basename(server.script)

	bash "install forever" do
		cwd _dir
		code "npm install forever -g"
	end

	bash "install dependencies" do
		cwd _dir
		code "su " + server.user + " --c 'npm install'"
	end

	bash "start" do
		code "su " + server.user + " --c 'forever start " + server.script + "'"
		not_if "su " + server.user + " --c 'forever list | grep -q \'" + server.script + "\''"
	end
end
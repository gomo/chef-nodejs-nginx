#
# Cookbook Name:: nodejs-nginx
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# include_recipe 'nginx'
# include_recipe 'nodejs'



node["nodejs-nginx"]["servers"].each do |server|
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

	directory _dir + '/logs' do
		owner "admin"
		group "admin"
		mode 0777
	end

	_conf = server.script.gsub('/', '_') + '.conf';
	template '/etc/nginx/conf.d/' + _conf do
		action 'create_if_missing'
		source 'nginx.conf.erb'
		owner 'root'
		group 'root'
		mode 0644
		variables(
			:nodejs_port => server.nodejs_port,
			:server_name => server.server_name,
			:base_dir => _dir
		)
	end
end

service 'nginx' do
  action [:start :restart]
end
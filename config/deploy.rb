require "bundler/capistrano"

server "192.241.246.187", :web, :app, :db, primary: true

set :application, "ludmillapsicologia.com.br"
# Next feature => remove root acces
set :user, "root"
set :deploy_to, "/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :shell, '/usr/bin/bash'

set :scm, "git"
set :repository, "git@github.com:esmerino/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
	desc "Start application"
	task :start, :roles => :app do
		run "cd #{current_path}; bundle exec rails s -p 8080 -e production"
	end

	desc "Stop application"
	task :stop, :roles => :app do
		run "ps|grep rails|grep -v grep|awk '{print $1}'|xargs kill -9"
	end

	desc "Install Ruby"
	task :ruby_install, :roles => :app do
		run "apt-get -y update"
		run "apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev git-core"
		run "cd /tmp"
		run "cd /tmp;wget http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p0.tar.gz"
		run "cd /tmp;tar -xvzf ruby-2.0.0-p0.tar.gz"
		run "cd /tmp;cd ruby-2.0.0-p0"
		run "cd /tmp;\.\/configure --prefix=/usr/local"
		run "cd /tmp;make"
		run "cd /tmp;make install"
	end
	
end
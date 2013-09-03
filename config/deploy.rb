require "bundler/capistrano"

server "192.241.246.187", :web, :app, primary: true

set :application, "ludmillapsicologia"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:esmerino/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
	desc "Start application"
	task :start, :roles => :app do
		run "cd #{current_path}; bundle exec rails s -p 6868 -e production -d"
	end

	desc "Stop application"
	task :stop, :roles => :app do
		run "ps aux|grep rails|grep -v grep|awk '{print $2}'|xargs kill -9"
	end

	desc "Install Ruby"
	task :ruby_install, :roles => :app do
		run "apt-get -y update"
		run "gem install bundler"
	end

	desc "Install Essential"
	task :install, :roles => :app do
		run "apt-get -y update"
		run "apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev git-core sqlite3 libsqlite3-dev python-software-properties"
	end

	desc "Adding User"
	task :add_user, :roles => :app do
		run "adduser deployer --ingroup admin"
	end
	
end
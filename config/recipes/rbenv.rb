set_default :ruby_version, "1.9.3-p125"



namespace :rbenv do
  def rbenv(command)
    run "rbenv #{command}", :pty => true do |ch, stream, data|
      if data =~ /\[sudo\].password.for/
        ch.send_data(Capistrano::CLI.password_prompt("Password:") + "\n")
      elsif data =~ /continue.with.installation\?.\(y\/N\)/
        ch.send_data(Capistrano::CLI.password_prompt("Value:") + "\n")
      else
        Capistrano::Configuration.default_io_proc.call(ch, stream, data)
      end
    end
  end

  desc "Install rbenv, Ruby, and the Bundler gem"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install curl git-core build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev"
    run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
    bashrc = <<-BASHRC
    if [ -d $HOME/.rbenv ]; then 
      export PATH="$HOME/.rbenv/bin:$PATH" 
      eval "$(rbenv init -)" 
      fi
      BASHRC
      put bashrc, "/tmp/rbenvrc"
      run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
      run "mv ~/.bashrc.tmp ~/.bashrc"
      run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
      run %q{eval "$(rbenv init -)"}
      rbenv "install #{ruby_version}"
      rbenv "global #{ruby_version}"
      run "gem install bundler --no-ri --no-rdoc"
      run "rbenv rehash"
    end
    after "deploy:install", "rbenv:install"
  end
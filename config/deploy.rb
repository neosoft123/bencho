require "capistrano"

set :application, "dev7am_staging"
set :rails_env, "staging"
set :deploy_to, "/var/www/rails/#{application}"
default_run_options[:pty] = true
ssh_options[:keys] = [File.join(ENV["HOME"], "ec2", "aws_bankio.pem")]

set :scm, "git"
set :repository, "git@github.com:agilisto/lovd-by-less.git"
set :branch, "lg"
set :deploy_via, :remote_cache
set :scm_verbose, true

set :use_sudo, false
set :user, "ubuntu"
set :ssh_options, { :forward_agent => true, :keys => [File.join(ENV["HOME"], "ec2", "aws_bankio.pem")]}
ssh_options[:forward_agent] = true
 
role :app, "smartcall.7.am"
role :web, "smartcall.7.am"
role :domain, "smartcall.7.am"
role :db, "smartcall.7.am", :primary => true
# role :db, "ec2-67-202-0-66.compute-1.amazonaws.com"

namespace :deploy do
  
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "chown -R apache:apache #{deploy_to}"
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

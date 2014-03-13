# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'nsiaf'
set :repo_url, 'git@github.com:elmerfreddy/nsiaf.git'

set :rvm_ruby_version, 'ruby-2.0.0-p353'
set :rvm_roles, [:app, :web]

# Default branch is :master
ask :branch, 'develop'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/nsiaf'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/newrelic.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  %w(seed drop create setup reset rollback).each do |command|
    desc "Run rake db:#{command}"
    task "db:#{command}" do
      on roles(:db), in: :sequence, wait: 5 do
        within release_path do
          with rails_env: :production do
            rake "db:#{command}"
          end
        end
      end
    end
  end
end
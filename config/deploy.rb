set :application, "linkcontrol"

set :repository,  "git://projects.tryphon.priv/linkcontrol"
set :scm, :git
set :git_enable_submodules, true
set :deploy_via, :copy

set :deploy_to, "/var/www/linkcontrol"

server "radio.dbx1.tryphon.priv", :app, :web, :db, :primary => true

set :keep_releases, 5
after "deploy:update", "deploy:cleanup" 
set :use_sudo, false
default_run_options[:pty] = true

after "deploy:update_code", "deploy:symlink_shared", "deploy:gems"
after "deploy:migrations", "deploy:fix_db_permissions"

set :rake, "bundle exec rake"

namespace :deploy do
  # Prevent errors when chmod isn't allowed by server
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "mkdir -p #{dirs.join(' ')} && (chmod g+w #{dirs.join(' ')} || true)"
  end

  desc "Symlinks shared configs and folders on each release"
  task :symlink_shared, :except => { :no_release => true }  do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/"
    run "ln -nfs #{shared_path}/config/production.rb #{release_path}/config/environments/"
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Install gems"
  task :gems, :roles => :app do
    run "cd #{release_path} && umask 002 && bundle install --path=#{shared_path}/bundle --without=development:test:cucumber"
  end

  desc "Fix database file permissions"
  task :fix_db_permissions, :roles => :db do
    sudo "chown www-data:src #{shared_path}/db/production.sqlite3"
    sudo "chmod g+w #{shared_path}/db/production.sqlite3"
  end

end

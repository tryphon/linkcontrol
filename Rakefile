# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

namespace :buildbot do
  task :setup do
    unless uptodate?("config/database.yml", "config/database.yml.sample") 
      cp "config/database.yml.sample", "config/database.yml" 
    end
  end
end

task :buildbot => ["buildbot:setup", "db:migrate", "db:test:prepare", "spec", "spec:plugins"]

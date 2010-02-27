begin
  require 'debian/build'

  include Debian::Build
  require 'debian/build/config'

  namespace "package" do
    Package.new(:linkcontrol) do |t|
      t.version = '0.1'
      t.debian_increment = 1

      t.source_provider = GitExportProvider.new do |source_directory|
        Dir.chdir("vendor/plugins/user_interface") do 
          sh "git archive --prefix=vendor/plugins/user_interface/ HEAD | tar -xf - -C #{source_directory}"      
        end
      end
    end
  end

  require 'debian/build/tasks'
rescue Exception => e
  puts "WARNING: Can't load debian package tasks (#{e.to_s})"
end

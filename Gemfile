source 'http://rubygems.org'

gem "rails", "2.3.8"

gem "inherited_resources", "~> 1.0.6"
gem "responders", "~> 0.4.7"
gem "delayed_job"

gem "i18n", "< 0.5.0"

gem "tryphon-box", :git => "git://projects.tryphon.priv/box"
gem "pige", :git => "git://projects.tryphon.priv/pige"

group :development do
  gem "sqlite3-ruby"
  gem "less"
  gem "rake-debian-build"
  gem "capistrano"
  gem "rake", "~> 0.8.7"
end

group :test do
  gem 'rspec-rails', '~> 1.3.2'
  gem 'remarkable_rails'

  gem "metalive", "0.0.1"
  gem "taglib-ruby", "0.4.0"
end

group :production do
  gem "SyslogLogger"
end

group :development, :test do
  gem "guard"
  gem 'guard-rspec'
  group :linux do
    gem 'rb-inotify'
    gem 'libnotify'
  end
end

build:
	gem install --no-rdoc --no-ri -v=2.3.5 rails
	cp config/database.yml.sample config/database.yml
# TODO run gem with --no-rdoc --no-ri
	rake gems:install
	rake gems:unpack:dependencies
	mkdir -p vendor/gems && cd vendor/gems && gem unpack --version 1.0.1 rack
	rake rails:freeze:gems

# use rake installed by rubygem
	~/.gem/ruby/1.8/bin/rake db:create db:migrate RAILS_ENV=production
	rm -f config/database.yml

install:
	cp -a app public vendor config lib db ${DESTDIR}usr/share/linkcontrol
	rm -f ${DESTDIR}usr/share/linkcontrol/config/environments/production.rb
	cp debian/database.yml debian/production.rb debian/apache2.conf ${DESTDIR}etc/linkcontrol/
	cp debian/syslog_logger.rb ${DESTDIR}usr/share/linkcontrol/lib

clean:
	rm -rf vendor/rails vendor/gems db/production.sqlite3


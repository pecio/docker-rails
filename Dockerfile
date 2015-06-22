# Dockerfile for a Rails app
#
# Based on http://blog.palominolabs.com/2014/05/12/introduction-to-docker-with-rails/
FROM ubuntu:latest

# Update Ubuntu
# Install RVM dependencies, cURL, PostgreSQL client and Node.js (for coffeescript and sass)
# Create rails user
RUN apt-get update -q &&\
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -qy &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -qy build-essential patch \
      gawk g++ make patch libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 \
      autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config \
      libffi-dev curl libpq-dev nodejs &&\
    /usr/sbin/useradd -m -s /bin/bash rails

# Add Rails app
ADD . rails-app

# Do not use app specified ruby
# Change ownership of directory
RUN /bin/rm -f rails-app/.rvmrc rails-app/.versions.conf rails-app/.ruby-version &&\
    /bin/sed -i.orig '/^[[:space:]]*ruby/d' rails-app/Gemfile &&\
    /bin/chown -R rails rails-app

# Switch to rails user
USER rails
ENV HOME /home/rails

# Install RVM and lastest MRI
RUN /bin/bash -c -l '/usr/bin/gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 &&\
                     /usr/bin/curl -sSL https://get.rvm.io | bash -s stable --ruby'

WORKDIR rails-app

ENV RACK_ENV production

# Inject unicorn (if not there)
# Use a config file if it is there, use ours otherwise
# Inject pg (if not there)
# Install bundler
# Install bundle
# Precompile assets
# Overwrite DB config
RUN /bin/grep -q "^[^#]*unicorn" Gemfile || echo 'gem "unicorn"' >> Gemfile &&\
    [ -f config/unicorn.rb ] || /bin/cp docker/extra/unicorn.rb config/unicorn.rb &&\
    /bin/grep -q "^[^#]*\bpg\b" Gemfile || echo 'gem "pg"' >> Gemfile &&\
    /bin/bash -c -l 'gem install bundler --no-ri --no-rdoc' &&\
    /bin/bash -c -l 'bundle install --without=development:test' &&\
    /bin/bash -c -l 'bundle exec rake assets:precompile' &&\
    /bin/cp -f docker/extra/database.yml config/database.yml

# Expose app
EXPOSE 3000
VOLUME ["/rails-app/public", "/rails-app/logs"]

# Setup command
CMD ["/bin/bash", "-c", "-l", "bundle exec unicorn -p 3000 -c config/unicorn.rb"]

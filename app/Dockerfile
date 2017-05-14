# Dockerfile for a Rails app
#
FROM ruby:alpine

# Create rails user to exec application
# Install needed Alpine packages
RUN /usr/sbin/adduser -D -s /bin/sh rails &&\
    /sbin/apk --no-cache add make gcc libc-dev linux-headers tzdata \
                             postgresql-dev git nodejs

# Add Rails app
ADD . rails-app

# Do not use app specified ruby
# Change ownership of directory
# Install entry point script
RUN /bin/sed -i.orig '/^[[:space:]]*ruby/d' rails-app/Gemfile &&\
    /bin/chown -R rails rails-app &&\
    /bin/cp /rails-app/docker/rails-entrypoint.sh /usr/local/bin

# Switch to rails user
USER rails
WORKDIR /rails-app

ENV RACK_ENV=production HOME=/home/rails PORT=3000

# Inject puma (if not there)
# Remove and reinject listen
# Use a config file if it is there, use ours otherwise
# Remove sqlite3 gem if present
# Remove pg gem if present
# Insert pg gem without version specification
# Overwrite DB config
# Remove Gemfile.lock so bundler rechecks versions
# Install bundle
# Precompile assets
RUN /bin/grep -q "^[^#]*\bpuma\b" Gemfile || echo 'gem "puma"' >> Gemfile &&\
    /bin/sed -i '/\blisten\b/d' Gemfile &&\
    echo 'gem "listen"' >> Gemfile &&\
    [ -f config/puma.rb ] || /bin/cp docker/config/puma.rb config/puma.rb &&\
    /bin/sed -i '/\bsqlite3\b/d' Gemfile &&\
    /bin/sed -i '/\bpg\b/d' Gemfile &&\
    echo 'gem "pg"' >> Gemfile &&\
    /bin/cp -f docker/config/database.yml config/database.yml &&\
    /bin/rm -f Gemfile.lock &&\
    /bin/sh -c -l 'bundle install --without=development:test' &&\
    /bin/sh -c -l 'bundle exec rake assets:precompile'

# Expose app
EXPOSE 3000
VOLUME ["/rails-app/public", "/rails-app/logs"]

# Setup entry point
ENTRYPOINT ["rails-entrypoint.sh"]
CMD ["puma", "-p", "3000", "-C", "config/puma.rb"]

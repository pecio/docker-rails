# Dockerfile for a Rails app
#
FROM ruby:alpine

RUN /usr/sbin/adduser -D -s /bin/sh rails &&\
    /sbin/apk --no-cache add make gcc libc-dev linux-headers tzdata \
                             postgresql-dev sqlite-dev git nodejs

# Add Rails app
ADD . rails-app

# Do not use app specified ruby
# Change ownership of directory
RUN /bin/sed -i.orig '/^[[:space:]]*ruby/d' rails-app/Gemfile &&\
    /bin/chown -R rails rails-app

# Switch to rails user
USER rails
ENV HOME /home/rails
WORKDIR rails-app

ENV RACK_ENV production

# Inject unicorn (if not there)
# Use a config file if it is there, use ours otherwise
# Remove pg gem if present
# Insert pg gem without version specification
# Overwrite DB config
# Remove Gemfile.lock so bundler rechecks versions
# Install bundle
# Precompile assets
RUN /bin/grep -q "^[^#]*unicorn" Gemfile || echo 'gem "unicorn"' >> Gemfile &&\
    [ -f config/unicorn.rb ] || /bin/cp docker/config/unicorn.rb config/unicorn.rb &&\
    /bin/sed -i.oldpg '/\bpg\b/d' Gemfile &&\
    echo 'gem "pg"' >> Gemfile &&\
    /bin/cp -f docker/config/database.yml config/database.yml &&\
    /bin/rm -f Gemfile.lock &&\
    /bin/sh -c -l 'bundle install --without=development:test' &&\
    /bin/sh -c -l 'bundle exec rake assets:precompile'

# Expose app
EXPOSE 3000
VOLUME ["/rails-app/public", "/rails-app/logs"]

# Setup command
CMD ["/bin/sh", "-c", "-l", "bundle exec unicorn -p 3000 -c config/unicorn.rb"]

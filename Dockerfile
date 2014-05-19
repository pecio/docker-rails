# Dockerfile for a Rails app
#
# Based on http://blog.palominolabs.com/2014/05/12/introduction-to-docker-with-rails/
FROM ubuntu

# Install cURL PostgreSQL client lib and Node.js (for coffeescript and sass)
# Fix /dev/fd problems
# Install RVM, requirements and latest MRI
# Undo /dev/fd hack
# Create rails user
RUN apt-get update -q &&\
    apt-get upgrade -qy &&\
    apt-get install -qy curl libpq-dev nodejs &&\
    echo "/bin/ln -sf /proc/self/fd /dev/fd" > /etc/profile.d/devfd.sh &&\
    chmod 0755 /etc/profile.d/devfd.sh &&\
    /bin/bash -c -l 'curl -sSL https://get.rvm.io | bash -s stable --ruby' &&\
    /bin/rm -f /etc/profile.d/devfd.sh &&\
    /usr/sbin/useradd -m -s /bin/bash -g rvm rails

# Add Rails app
ADD . rails-app

# Do not use app specified ruby
# Change ownership of directory
RUN /bin/rm -f rails-app/.rvmrc rails-app/.versions.conf rails-app/.ruby-version &&\
    /bin/sed -i.orig '/^[[:space:]]*ruby/d' rails-app/Gemfile &&\
    /bin/chown -R rails rails-app

# Switch to rails user
USER rails

WORKDIR rails-app

# Inject unicorn (if not there)
# Use a config file if it is there, use ours otherwise
# Install bundler
# Install bundle
# Precompile assets
# Overwrite DB config
RUN /bin/bash -c '/bin/grep -q "^[^#]*unicorn" Gemfile || echo "gem \"unicorn\"" >> Gemfile' &&\
    /bin/bash -c '[[ -f config/unicorn.rb ]] || /bin/cp docker/extra/unicorn.rb config/unicorn.rb' &&\
    /bin/bash -c -l 'gem install bundler --no-ri --no-rdoc' &&\
    /bin/bash -c -l 'bundle install --without=development:test' &&\
    /bin/bash -c -l 'RAILS_ENV=production bundle exec rake assets:precompile' &&\
    /bin/cp -f docker/extra/database.yml config/database.yml

# Expose app
EXPOSE 3000
VOLUME ["/rails-app/public", "/rails-app/logs"]

# Setup command
CMD ["/bin/bash", "-c", "-l", "RAILS_ENV=production bundle exec unicorn -p 3000 -c config/unicorn.rb"]

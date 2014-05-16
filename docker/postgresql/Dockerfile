# PostgreSQL 9.3 server for Rails
FROM ubuntu

RUN apt-get update &&\
    apt-get install -qy postgresql-9.3

# The following (the tricky part) is copied almost verbatim from
# docker.io example (http://docs.docker.io/examples/postgresql_service/)
USER postgres

# Create Postgres user and database
# Enable remote network access
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER rails WITH SUPERUSER PASSWORD 'rails';" &&\
    createdb -O rails rails &&\
    echo "host all all   0.0.0.0/0 md5" >> /etc/postgresql/9.3/main/pg_hba.conf &&\
    echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose PostgreSQL port
EXPOSE 5432

# Expose volumes for config, logs and databases
VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Setup command for PostgreSQL server
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]

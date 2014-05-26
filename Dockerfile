# Trytond 3.2
#
# * Also installs postgres-9.3, the recommended database engine
#
# VERSION	3.2.0.1

FROM ubuntu:14.04
MAINTAINER Sharoon Thomas <sharoon.thomas@openlabs.co.in>

# Update package repository
RUN apt-get update
RUN apt-get -y -q install sudo

# Setup UTF8 locale
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN apt-get -y -q install language-pack-en-base
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure --frontend noninteractive locales

# Install setuptools to install pip
RUN apt-get -y -q install python-setuptools python-dev
# setuptools sucks! install pip
RUN easy_install pip

# Install supervisor since docker will only run one command as its entrypoint
RUN apt-get -y -q install supervisor

# Tryton supports multiple databases and the choice of database is left to you
# Install postgres
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y -q install python-software-properties software-properties-common libpq-dev
RUN apt-get -y -q install postgresql-9.3 postgresql-client-9.3
RUN sed -i 's/ssl = true/ssl = false/' /etc/postgresql/9.3/main/postgresql.conf
RUN service postgresql start

# Install the postgres python database driver
RUN pip install psycopg2

# Add postgres to supervisor services
ADD supervisor-progs/postgresql.conf /etc/supervisor/conf.d/postgresql.conf

# Allow postgres to allow passwordless access from local
RUN sed -i 's/host    all             all             127.0.0.1\/32            md5/host all all 127.0.0.1\/32 trust/' /etc/postgresql/9.3/main/pg_hba.conf

# Create tryton user in postgres
RUN service postgresql start &&\
      sudo -u postgres psql -h 127.0.0.1 -c "CREATE ROLE tryton WITH LOGIN PASSWORD 'tryton' CREATEDB;" &&\
      sudo -u postgres createdb -h 127.0.0.1 -O tryton -E UNICODE -l en_US.UTF8 -T template0 tryton

# Install latest trytond in 3.2.x series
RUN apt-get -y -q install python-lxml
RUN pip install 'trytond>=3.2,<3.3'

# Copy trytond.conf from local folder to /etc/trytond.conf
RUN useradd --system tryton
ADD trytond.conf /etc/trytond.conf
ADD supervisor-progs/trytond.conf /etc/supervisor/conf.d/trytond.conf

# Create an empty folder for tryton data store
RUN mkdir -p /var/lib/trytond
RUN chown tryton /var/lib/trytond

# Intiialise the database
RUN echo admin > /.trytonpassfile
ENV TRYTONPASSFILE /.trytonpassfile
RUN service postgresql start && trytond -c /etc/trytond.conf -i all -d tryton
# TODO: Setup openoffice reporting

EXPOSE 	8000
CMD ["/usr/bin/supervisord", "-n"]

# Trytond 3.2
#
# * Also installs postgres-9.3, the recommended database engine
#
# VERSION	3.2.0.1

FROM ubuntu:13.04
MAINTAINER Sharoon Thomas <sharoon.thomas@openlabs.co.in>

# Update package repository
RUN apt-get update

# Install setuptools to install pip
RUN apt-get -y -q install python-setuptools python-dev
# setuptools sucks! install pip
RUN easy_install pip

# Install supervisor since docker will only run one command as its entrypoint
RUN apt-get install supervisor
# First make ssh itself a supervisor service.
ADD supervisor-progs/sshd.conf /etc/supervisor/conf.d/sshd.conf
# Start supervisor
RUN supervisord

# Tryton supports multiple databases and the choice of database is left to you
# Install postgres
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y -q install python-software-properties software-properties-common libpq-dev
RUN apt-get -y -q install postgresql-9.3 postgresql-client-9.3

# Install the postgres python database driver
RUN pip install psycopg2

# Add postgres to supervisor services
ADD supervisor-progs/postgresql.conf /etc/supervisor/conf.d/postgresql.conf
RUN supervisorctl reload

# Run the rest of the commands as the ``postgres`` user
USER postgres

# Create tryton user in postgres
RUN psql -h localhost --command "CREATE USER tryton WITH SUPERUSER PASSWORD 'tryton';"

# Switch the user back to root
USER root

# Install latest trytond in 3.2.x series
RUN pip install 'trytond>=3.2,<3.3'

# Copy trytond.conf from local folder to /etc/trytond.conf
ADD trytond.conf /etc/trytond.conf

# Create an empty folder for tryton data store
RUN mkdir -p /var/lib/trytond
RUN chown tryton:tryton /var/lib/trytond

# TODO: Setup openoffice reporting

EXPOSE 	8000

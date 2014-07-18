# Trytond 3.0
#
# VERSION	3.0.0.1

FROM ubuntu:14.04
MAINTAINER Sharoon Thomas <sharoon.thomas@openlabs.co.in>

# Update package repository
RUN apt-get update
RUN apt-get -y -q install sudo



# Setup environment and UTF-8 locale
ENV DEBIAN_FRONTEND noninteractive
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN apt-get -y -q install language-pack-en-base
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Install setuptools to install pip
RUN apt-get -y -q install python-setuptools python-dev libpq-dev
# setuptools sucks! install pip
RUN easy_install pip

# Install supervisor since docker will only run one command as its entrypoint
RUN apt-get -y -q install supervisor

# Install the postgres python database driver
RUN pip install psycopg2

# Install latest trytond in 3.0.x series
RUN apt-get -y -q install python-lxml
RUN pip install 'trytond>=3.0,<3.1'

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
# TODO: Setup openoffice reporting

# Allow SSH access to the server
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd 
RUN echo 'root:password' |chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
ADD supervisor-progs/sshd.conf /etc/supervisor/conf.d/sshd.conf

EXPOSE 	8000 22
CMD ["/usr/bin/supervisord", "-n"]

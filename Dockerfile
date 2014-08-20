FROM openlabs/tryton:3.2
MAINTAINER Umang Arora <umang.arora@openlabs.co.in>

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Install dependencies for wkhtmltopdf
RUN apt-get install -y openssl build-essential xorg libssl-dev libxrender-dev wget xvfb git-core fontconfig curl

# Install dependencies of QT
RUN apt-get install -y libfontconfig1-dev libfreetype6-dev libx11-dev libxcursor-dev libxext-dev libxfixes-dev libxft-dev libxi-dev libxrandr-dev

# Install QT from git repository
ADD install_qt.sh /install_qt.sh
RUN /install_qt.sh

# Install wkhtmltopdf 0.12.1 stable
RUN wget http://citylan.dl.sourceforge.net/project/wkhtmltopdf/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
RUN dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
RUN mv /usr/local/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf_orig
ADD wkhtmltopdf /usr/local/bin/wkhtmltopdf

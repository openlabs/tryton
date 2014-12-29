# Tryton Dockerfile

This Dockerfile will run the steps required to build a working image of
Tryton. The build is based on the `ubuntu` base image provided by docker.

## Usage

Fetch the repository from docker

    docker pull openlabs/tryton

Create a new container using the image

    docker run -d -P 8000 openlabs/tryton

* The `-d` option indicates that the container should be run in daemon
  mode.
* The `-p` option and it's value `8000` instructs docker to bind TCP port 8000
  of the container to a dynamically allocated TCP port on all available
  interfaces of the host machine.
  See [ports documentation](http://docs.docker.io/use/port_redirection/#port-redirection)
  for a more detailed explanation on how the port exposed by the container is
  bound to the host running the docker container.

To find the port that tryton in now bound to

    docker ps

The output in the PORTS column should look like `0.0.0.0:49153->8000/tcp`.
You should now be able to connect to tryton on the port 49153. (Note:
Substitute the port number with what is displayed on your docker host.)

**SSH into the container (Deprecated)**

The container originally did support SSH but was subsequently removed.
[Read Why](http://blog.docker.com/2014/06/why-you-dont-need-to-run-sshd-in-docker/)

## Running from docker container

You can access the docker container and work from within it.::

    docker run -i -t openlabs/tryton /bin/bash

On execution of the command a new prompt within the container should be
available to you. Remember that trytond (default service) is not started
automatically for you when you access the container in this manner. To
start trytond, run::

    trytond -c /etc/trytond.conf

## More details

This is a minimalistic Docker container for Tryton which could be used in
both production and developemnt. Further step if you intend on using this
as a base image is below.

**Extending this image**

This docker image is a minimal base on which you should extend and write
your own modules. The following example steps would be required to say
make your setup work with postgres and install the sale module.


    # Trytond 3.4 with Sale module and Postgres
    #

    FROM openlabs/tryton:3.4
    MAINTAINER Sharoon Thomas <sharoon.thomas@openlabs.co.in>

    # Setup psycopg2 since you want to connect to postgres
    # database
    RUN apt-get -y -q install python-dev libpq-dev
    RUN pip install psycopg2

    # Setup the sale module since it is a required for this
    # custom setup
    RUN pip install 'trytond_sale>=3.4,<3.5'

    # Copy new trytond.conf from local folder to /etc/trytond.conf
    # The new trytond also has credentials to connect to the postgres
    # server which is accessible elsewhere
    ADD trytond.conf /etc/trytond.conf

This example can be downloaded as a [gist](https://gist.github.com/sharoonthomas/a75cf7b02173fa3556cf).

## TODO

* Ability to load configuration parameters from environment variables.
  [See why?](http://12factor.net/config)

## Authors and Contributors

This image was built at [Openlabs](http://www.openlabs.co.in).

## Professional Support

This image is professionally supported by [Openlabs](http://www.openlabs.co.in).
If you are looking for on-site teaching or consulting support, contact our
[sales](mailto:sales@openlabs.co.in) and [support](mailto:support@openlabs.co.in) teams.

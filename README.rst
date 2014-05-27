Tryton Dockerfile
=================

This Dockerfile will run the steps required to build a working image of
Tryton. It also installs postgres. The build is based on the `ubuntu` base
image provided by docker.

Usage
-----

Fetch the repository from docker::

    docker pull openlabs/tryton

Create a new container using the image::

    docker run -d -P 8000 openlabs/tryton

* The `-d` option indicates that the container should be run in daemon
  mode.
* The `-p` option and it's value `8000` instructs docker to bind TCP port 8000
  of the container to a dynamically allocated TCP port on all available
  interfaces of the host machine.
  See `ports documentation 
  <http://docs.docker.io/use/port_redirection/#port-redirection>`_ for a
  more detailed explanation on how the port exposed by the container is
  bound to the host running the docker container.

To find the port that tryton in now bound to::

    docker ps

The output in the PORTS column should look like `0.0.0.0:49153->8000/tcp`.
You should now be able to connect to tryton on the port 49153. (Note:
Substitute the port number with what is displayed on your docker host.)

SSH into the container
``````````````````````

The docker container also runs an ssh daemon which will let you connect to
the container over ssh. Though the port 22 is exposed by the container, it
may not be bound to the container host if you have not explicitly bound it
using `-p 22`.

.. tip::

   You could also use `-P` (in capital) to bind all the ports exposed to
   the container. `Read more <http://docs.docker.io.s3-website-us-west-2.amazonaws.com/reference/run/#expose-incoming-ports>`_

If the port is already bound to the host, you should be able to see the
port on using `docker ps`. You can then connect via SSH using::

    ssh root@localhost -p <port>

*Substitute port with the port in the 49*** range indicated by docker ps*

Running from docker container
-----------------------------

You can access the docker container and work from within it.::

    docker run -i -t openlabs/tryton /bin/bash

On execution of the command a new prompt within the container should be
available to you. Remember that postgres and tryton are not started
automatically for you when you access the container in this manner. To
start both services, run::

    supervisord

To see the current status of the processes::

    supervisorctl status

This should show the status of postgres and tryton.

Perhaps, you want to run tryton yourself::

    supervisorctl stop tryton
    trytond -c /etc/trytond.conf

and you can do everything you normally do with the tryton daemon script.

More details
------------

The docker image entry point is the supervisor daemon which then runs
postgres and tryton on separate processes.

  * `Postgres supervisor configuration <supervisor-progs/postgresql.conf>`_
  * `Tryton supervisor configuration <supervisor-progs/trytond.conf>`_
  * `SSH supervisor configuration <supervisor-progs/sshd.conf>`_

The tryton configuration used by tryton is at `/etc/trytond.conf
<trytond.conf>`_

Authors and Contributors
------------------------

This image was built at `Openlabs <http://www.openlabs.co.in>`_. 

Professional Support
--------------------

This image is professionally supported by `Openlabs <http://www.openlabs.co.in>`_.
If you are looking for on-site teaching or consulting support, contact our
`sales <mailto:sales@openlabs.co.in>`_ and `support
<mailto:support@openlabs.co.in>`_ teams.

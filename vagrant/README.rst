Development environment for MONARC
==================================

Vagrant is convenient to use in order to setup your development environment.

This VM uses `synced folders <https://www.vagrantup.com/docs/synced-folders/>`_
feature of Vagrant in order to let you work on the MONARC source code on your
host machine while the softwares (Apache, PHP, MariaDB, etc.) and libraries
will be installed on the guest Vagrant machine.


Installation of VirtualBox and Vagrant
--------------------------------------

.. code-block:: bash

    $ sudo apt-get install virtualbox vagrant
    $ vagrant plugin install vagrant-disksize


Deployment of the front office
------------------------------

MONARC will be automatically deployed on Ubuntu 26.04 LTS with PHP 8.4.28 or later
in the 8.4 release line. Provisioning uses the maintainer's ``packages.sury.org/php`` repository for
Ubuntu 26.04 (Resolute) and checks the PHP
version before installing application dependencies.

.. code-block:: bash

    $ git clone https://github.com/monarc-project/MonarcAppFO
    $ cd MonarcAppFO/vagrant
    $ vagrant up

Once the VM will be configured by Vagrant, go to the address
http://127.0.0.1:5001

The username is *admin@admin.localhost* and the password is *admin*.

You can now edit the source code with your favorite editor and test it in your
browser. The only thing is to not forget to restart Apache in the VM after a
modification.

The StatsService service will be configured, launched and accessible by the following url:
http://127.0.0.1:5005

------------------------------
Run tests.
The test can be run from Monarc root folder (/home/ubuntu/monarc) of your vagrant VM (params in square brackets are optional):

sudo ./bin/phpunit [--testsuite Functional | --testsuite Integration | --testsuite Unit]

In case of changing the DB configuration (tests/local.php) you can run them from your host machine.

Ubuntu 26.04 provisioning
------------------------

Use Vagrant 2.4 or later and a current VirtualBox release appropriate for the
host architecture. The ``bento/ubuntu-26.04`` box provides amd64 and arm64 images.
MONARC retains PHP >=8.4.28 <8.5; Ubuntu's default PHP 8.5 is not used.

Node.js 16.20.2 matches the existing frontend release build runtime. Its official
binary archive is checked against the published SHA-256 checksums. Native build
dependencies are installed for canvas. A Node major upgrade is separate from
this guest OS change.

The bootstrap is for a fresh guest. Existing VMs are not upgraded by changing the
box name or running ``vagrant provision``. Preserve an existing VM and create a
separate Ubuntu 26.04 instance, for example:

.. code-block:: bash

    $ VAGRANT_DOTFILE_PATH=.vagrant/ubuntu-26.04 vagrant up

Keep the two instances from using the same host ports. The bootstrap checks the
guest OS before changing packages, installs the pinned frontend revisions, and
runs ``scripts/upgrade-db.sh`` to apply Core and office migrations. MariaDB root
administration uses the guest's local Unix socket.

Every privileged APT command passes ``DEBIAN_FRONTEND=noninteractive`` through
``sudo`` so unattended package configuration does not depend on sudo preserving
the caller's environment.

Ubuntu 26.04's Apache service makes home directories read-only. The Vagrant
bootstrap creates ``/etc/systemd/system/apache2.service.d/monarc-vagrant.conf``
with ``ReadWritePaths`` entries for ``/home/vagrant/monarc/data`` and
``/home/vagrant/monarc/public/captcha``, then reloads systemd before restarting
Apache. These exceptions allow runtime caches, uploads and CAPTCHA images in
the synced checkout while its application source remains read-only to the service.

The statistics service uses a Poetry-managed Python 3.12 environment rather than
the guest's system Python. Poetry is installed from Ubuntu packages, and systemd
runs ``/usr/bin/poetry`` with the current ``app.py`` entry point.

Validation on 2026-11-24: both Vagrantfiles pass ``vagrant validate``, both
bootstraps pass Bash syntax checks, and regression tests cover rejection of older
guests and stopping after an APT index failure. PHP 8.4 installation, frontend
``npm ci``/canvas loading and Poetry-managed Python 3.12 were checked in a
disposable Ubuntu 26.04 arm64 container. Full VM provisioning, database migrations
and application startup still need an end-to-end Vagrant run.

Validation on 2026-11-26: four regression tests pass, including all package
commands under simulated sudo environment filtering and both Apache overrides.
An Ubuntu 26.04 container reproduced HTTP 500 with a read-only home directory;
with each override's writable paths, Apache/PHP returned HTTP 200, wrote cache
and CAPTCHA files, and could not write application source. Both service
configurations passed ``systemd-analyze verify``. Noninteractive package
configuration also completed with stdin closed. This checks the fixes in a mount
namespace; a complete Vagrant VM provision has not been rerun.

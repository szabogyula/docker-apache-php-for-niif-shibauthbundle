Federated webapp runner for develop php application in federated environment
=============================================================================

Warning: this container under strong development. Be careful!

Configure for local development
--------------------------------

* First, you need [Docker enviroment](https://docker.com/toolbox) on your machine
* You need a mysql, or mariadb instance, if you don't have yet, it is easy to run in docker: `docker run -d -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD="yes" mysql`
* Rename `ansible/index.yml.dist` to `ansible/index.yml`, then add your config options into this file (`vars` section)


Build
-----

`docker build -t szabogyula/apache-php-for-niif-shibauthbundle .`

Run
---

__Set resolving__
 Edit your `/etc/hosts` file in your machine. All hostnames `project.local` must show to local Docker IP address, which is usually `192.168.99.100 project.local` or on Ubuntu 16.04 `127.0.0.1 project.local`

You can override the default project.local hostname by environment variable: `PROJECT_HOSTNAME`

example:

`docker run -d -p 80:80 -p 443:443 -p 8080:8080 -e PROJECT_HOSTNAME=example.com -v /path/to/webapp_project:/var/www/project szabogyula/apache-php-for-niif-shibauthbundle`

__Own logfiles to tailon__
Provide your interest logfiles into the LOGFILES environment variable, separate with commas:

`docker run -d -p 80:80 -p 443:443 -p 8080:8080 -e LOGFILES=/var/www/project/var/logs/dev.log,/var/www/project/var/logs/prod.log -v /path/to/webapp_project:/var/www/project szabogyula/apache-php-for-niif-shibauthbundle`


__Run the docker container__
Run for development (adjust the example hostnames before running!): `docker run -d -p 80:80 -p 443:443 -p 8080:8080 --add-host project.local:127.0.0.1
 -v /path/to/webapp_project:/var/www/project szabogyula/apache-php-for-niif-shibauthbundle
 `

__Set the DocumentRoot__
You can set the relative document root instead of `web` by set `DOCUMENT_ROOT` environment variable.

in case of html directory:
` ...  -e DOCUMENT_ROOT=/var/www/project/html ...`

__Access the webapp__
* 80 and 443 port is the application, and there is a tailon at 8080 port

__Filebeat__
If you mount a correct /tmp/filebeat.yml, the filebeat will be start with these configuration.

` docker run ... -v /path/to/filebeat.yml:/tmp/filebeat.yml ...`

Use
---

__Xdebug__

The xdebug is installed into php. You have to set an alias to your ethernet interface 10.254.254.254 ip address.

On Mac: `sudo ifconfig lo0 alias 10.254.254.254`

In PHPstorm you should set
Preferences > Debug > DBGp proxy
* host: 10.254.254.254
* port: 9000
* ide key: PHPSTORM

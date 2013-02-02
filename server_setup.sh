#!/bin/sh

echo "BEGIN: Setting up uwsgi and nginx ..."

# Install libs
# ------------
echo "deb http://nginx.org/packages/ubuntu/ precise nginx
deb-src http://nginx.org/packages/ubuntu/ precise nginx" > /etc/apt/sources.list.d/nginx.list
wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
rm nginx_signing.key
apt-get update
apt-get install nginx
sudo apt-get install python-dev build-essential python-pip
sudo pip install uwsgi
sudo pip install virtualenv


# Setup users
# -----------
sudo useradd -c 'uwsgi user,,,' -g nginx -d /nonexistent -s /bin/false uwsgi
sudo usermod -a -G nginx $USER


# Setup services
# --------------
sudo rm /etc/init/uwsgi.conf

echo 'description "uWSGI"
start on runlevel [2345]
stop on runlevel [06]

respawn

exec uwsgi --master --processes 4 --die-on-term --uid uwsgi --gid nginx --socket /tmp/uwsgi.sock --chmod-socket 660 --no-site --vhost --logto /var/log/uwsgi.log' > /etc/init/uwsgi.conf

sudo rm /etc/logrotate.d/uwsgi

echo '/var/log/uwsgi.log {
    rotate 10
    daily
    compress
    missingok
    create 640 uwsgi adm
    postrotate
        initctl restart uwsgi >/dev/null 2>&1
    endscript
}' > /etc/logrotate.d/uwsgi

sudo touch /var/log/uwsgi.log
sudo logrotate -f /etc/logrotate.d/uwsgi

sudo rm /etc/nginx/conf.d/default.conf


# Restart services
# ----------------
sudo service uwsgi restart
sudo service nginx restart


echo "END: ... Setting up uwsgi and nginx complete."
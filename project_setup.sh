#!/bin/sh

# 
# Usage:
# project_setup.sh -n project_name -s localhost -p 80
 
# Get input arguments
# -------------------
while getopts n:s:p: option
do
        case "${option}"
        in
                n) PROJECT_NAME=${OPTARG};;
                s) SERVER_NAME=${OPTARG};;
                p) SERVER_PORT=${OPTARG};;
        esac
done
 
 
# Check valid, and set defaults
# -----------------------------
if [ -z "$PROJECT_NAME" ];
then
        echo "ERROR: Missing PROJECT_NAME (-n project_name)"
        exit 1
fi
 
if [ -z "$SERVER_NAME" ];
then
        SERVER_NAME="localhost"
fi
 
if [ -z "$SERVER_PORT" ];
then
        SERVER_PORT="80"
fi
 
echo "BEGIN: project $PROJECT_NAME ..."
echo " - Server: $SERVER_NAME:$SERVER_PORT"
 
 
# Confirmation by user
# --------------------
read -p "Are you sure? (y/n)" -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
echo ""
 
echo "do stuff"
 
# Add a new user for the project
# ------------------------------
sudo adduser $PROJECT_NAME
sudo usermod -a -G nginx $PROJECT_NAME
 
 
# Setup ssh and web directories
# -----------------------------
 
sudo mkdir /home/$PROJECT_NAME/.ssh
sudo mkdir /home/$PROJECT_NAME/www
sudo chown -R $PROJECT_NAME:nginx /home/$PROJECT_NAME/www
sudo chmod -R g+w /home/$PROJECT_NAME/www
sudo cp ~/.ssh/authorized_keys /home/$PROJECT_NAME/.ssh/
sudo chown -R $PROJECT_NAME:$PROJECT_NAME /home/$PROJECT_NAME/.ssh
sudo chmod 700 /home/$PROJECT_NAME/.ssh
sudo chmod 600 /home/$PROJECT_NAME/.ssh/*
 
 
# Create virtual environment and config
# -------------------------------------
cd /home/$PROJECT_NAME
 
virtualenv ./env

sudo chown -R $PROJECT_NAME:nginx /home/$PROJECT_NAME/env
sudo chmod -R g+w /home/$PROJECT_NAME/env

source env/bin/activate
pip install Flask
deactivate
 
echo "server {
    listen       $SERVER_PORT;
    server_name  $SERVER_NAME;
 
    location /public {
        autoindex on;    
        alias /home/$PROJECT_NAME/www;  
    }

    location / {
        include uwsgi_params;
        uwsgi_pass unix:/tmp/uwsgi.sock;
        uwsgi_param UWSGI_PYHOME /home/$PROJECT_NAME/env;
        uwsgi_param UWSGI_CHDIR /home/$PROJECT_NAME;
        uwsgi_param UWSGI_MODULE manage;
        uwsgi_param UWSGI_CALLABLE app;
    }
 
    error_page   404              /404.html;
    error_page   500 502 503 504  /50x.html;

    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}" > /etc/nginx/conf.d/$PROJECT_NAME.conf
 
 
# Restart services
# ----------------
sudo service uwsgi restart
sudo service nginx restart
 
echo "END: project $PROJECT_NAME complete."
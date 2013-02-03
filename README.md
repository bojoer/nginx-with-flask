Instructions
============

Following these instructions will setup 2 wesites 'dev.example.com' and 'dev2.example.com'.


Domain Side:
------------
Add an A Record:
- dev.example.com 185.14.187.99 A (Address) 1800
- dev2.example.com 185.14.187.99 A (Address) 1800


Server Side:
------------
Copy to root home: 
- sever_setup.sh
- project_setup.sh
- server_restart.sh

Run:
- . ~/server_setup.sh
- . ~/project_setup.sh -n dev -s dev.example.com
- . ~/project_setup.sh -n dev2 -s dev2.example.com

Load and update config:
- nano /etc/nginx/nginx.conf

    http {
        server_names_hash_bucket_size 64;
        ...
    }


Client Side:
------------
Load and update deployment config:
- deploy/.deploy
    master dev@185.14.187.99 . false

Run:
- virtualenv ./env
- source env/bin/activate
- pip install ...
- . deploy.sh


Server Side:
------------
Run
- . ~/server_restart.sh
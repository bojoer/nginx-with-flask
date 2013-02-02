Instructions
------------

Server Side:
------------
Copy to root home: 
 - sever_setup.sh
 - project_setup.sh
 - server_restart.sh


Run
. ~/server_setup.sh
. ~/project_setup.sh -n dev -s dev.markdessain.com
. ~/project_setup.sh -n dev2 -s dev2.markdessain.com


Load and update config:
nano /etc/nginx/nginx.conf

http {
    server_names_hash_bucket_size 64;
    ...
}


Client Side:
------------
dev/ 
	virtualenv ./env
	source env/bin/activate
	pip install ...
	. deploy.sh

dev2/ 
	virtualenv ./env
	source env/bin/activate
	pip install ...
	. deploy.sh



Server Side:
------------
Run
. ~/server_restart.sh
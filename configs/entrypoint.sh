#!/usr/bin/env sh

# The purpose of the entrypoint here is to configure nginx 
# according to the environmental variables provided to docker.

USE_NGINX_MAX_UPLOAD=${NGINX_MAX_UPLOAD:-0}
USE_NGINX_WORKER_PROCESSES=${NGINX_WORKER_PROCESSES:-1}
NGINX_WORKER_CONNECTIONS=${NGINX_WORKER_CONNECTIONS:-1024}
USE_LISTEN_PORT=${LISTEN_PORT:-80}

if [ -f /django-home/test1/django-nginx.conf ]; then
  cp /django-home/test1/django-nginx.conf /etc/nginx/django.conf
else
  content='user www-data;\n'
  content=$content"worker_processes ${USE_NGINX_WORKER_PROCESSES};\n"
  content=$content'error_log stderr;\n'
  content=$content'pid /var/run/nginx.pid;\n'
  content=$content'events {\n'
  content=$content"   worker_connections ${NGINX_WORKER_CONNECTIONS};\n"
  content=$content'}\n'
  content=$content'http {\n'
  content=$content'    include /etc/nginx/mime.types;\n'
  content=$content'    default_type application/octet-stream;\n'
  content=$content'    sendfile on;\n'
  content=$content'    access_log /dev/stdout;\n'
  content=$content'    keepalive_timeout 65;\n'
  content=$content'    include /etc/nginx/conf.d/*.conf;\n'
  content=$content'}\n'
  content=$content'daemon off;\n'
  
  printf "$content" > /etc/nginx/nginx.conf

  content_server='server {\n'
  content_server=$content_server"    listen ${USE_LISTEN_PORT};\n"
  content_server=$content_server'    location /{\n'
  content_server=$content_server'        include uwsgi_params;\n'
  content_server=$content_server'        uwsgi_pass unix:///tmp/uwsgi.sock;\n'
  content_server=$content_server'    }\n'
  content_server=$content_server'}\n'

  printf "$content_server" > /etc/nginx/conf.d/nginx.conf

  echo '' > /etc/nginx/conf.d/default.conf
fi
exec "$@"

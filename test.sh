#!/usr/bin/env bash

docker exec -it 0_webserver_1 /django-home/manage.py test polls

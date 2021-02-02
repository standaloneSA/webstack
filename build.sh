#!/bin/bash

docker-compose build
if [ "$1" == '--all' ] ; then 
  docker build -t test0 ./ 
fi

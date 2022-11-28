#!/bin/sh
set -e

# docker-compose up --build test-db

docker-compose -f test_db/docker-compose.yml --env-file=test_db/.env_testdb up --build -d

# pass docker env (local address of db) / set envs

sam build

networkInfo=`docker network ls | grep test_db`

IFS=' ' read -r -a networkInfoArray <<< "$networkInfo"

# sam local invoke "HelloWorldFunction" -e events/event.json --docker-network ${networkInfoArray[0]} --force-image-build --env-vars env_testdb.json

sam local start-api --docker-network ${networkInfoArray[0]} --env-vars env_testdb.json

# run integration test

# deployment

# sam deploy 

# docker-compose down test-db

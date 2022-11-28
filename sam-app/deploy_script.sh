#!/bin/sh
set -e

# Builds test database in a separate docker network. Ensure that your docker is running.
docker-compose -f test_db/docker-compose.yml --env-file=test_db/.env_testdb up --build -d

# pass docker env (local address of db) / set envs

# Builds our lambda function.
sam build

# Fetches the docker network of our test database
networkInfo=`docker network ls | grep test_db`
IFS=' ' read -r -a networkInfoArray <<< "$networkInfo"

# sam local invoke "HelloWorldFunction" -e events/event.json --docker-network ${networkInfoArray[0]} --force-image-build --env-vars env_testdb.json

# Runs our lambda functions locally. We also connect to our test db's docker network.
sam local start-api --docker-network ${networkInfoArray[0]} --env-vars env_testdb.json

# run integration test


# Deploys our application if the tests passed.
# sam deploy 

# docker-compose down test-db

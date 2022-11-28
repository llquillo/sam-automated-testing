#!/bin/sh
set -e

# Builds test database in a separate docker network. Ensure that your docker is running.
docker-compose -f test_db/docker-compose.yml --env-file=test_db/.env_testdb up --build -d


# Fetches the docker container ID of our test-db for sql dump import.
dockerContInfo=`docker ps | grep test-db`
IFS=' ' read -r -a dockerContInfoArray <<< "$dockerContInfo"


# Imports the sql test dump.
docker exec -i $dockerContInfoArray psql -U docker -d test_db -p 5432 < test_db/test_dump.sql


# Builds our lambda function.
sam build


# Fetches the docker network of our test database.
networkInfo=`docker network ls | grep test_db`
IFS=' ' read -r -a networkInfoArray <<< "$networkInfo"

# sam local invoke "HelloWorldFunction" -e events/event.json --docker-network ${networkInfoArray[0]} --force-image-build --env-vars env_testdb.json


# Runs our lambda functions locally. We also connect to our test db's docker network.
sam local start-api --docker-network ${networkInfoArray[0]} --env-vars env_testdb.json & disown


# run integration test
source bin/activate
pip3 install -r tests/requirements.txt
python3 -m pytest tests/integration


# Deploys our application if the tests passed.
# sam deploy 


# Stops our local lambda server.
procInfo=`ps aux | grep sam[[:space:]]local`
IFS=' ' read -r -a procArr <<< "$procInfo"
kill ${procArr[1]}


# Stops our test-db docker container
docker-compose -f test_db/docker-compose.yml down

# TODO:
# 1. integration test - create a INITIAL sample integration test and incorporate to deployment script - done
# 2. implement multi-stage builds for test database
# 3. create dump sql for test db and import/add to Dockerfile - done
# 4. create integration test for api calls connecting to db - done
# 5. test everything - done


# psql -h localhost -p 5432 -U docker -d test_db
# \c
# \dt
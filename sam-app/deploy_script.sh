#!/bin/sh
set -e

cleanup() {
  # Stops our local lambda server.
  procInfo=`ps aux | grep sam[[:space:]]local`
  IFS=' ' read -r -a procArr <<< "$procInfo"
  if [ -n "${procArr[1]}" ]; then
    kill ${procArr[1]}
  fi

  # Stops our test-db docker container.
  docker-compose -f test_db/docker-compose.yml down
}

trap "cleanup" ERR

# Builds test database in a separate docker network. Ensure that your docker is running.
docker-compose -f test_db/docker-compose.yml --env-file=test_db/.env_testdb up --build -d

sleep 10

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


# Runs our lambda functions locally. We also connect to our test db's docker network.
sam local start-api --docker-network ${networkInfoArray[0]} --env-vars env_testdb.json & disown


# Runs our integration tests.
source bin/activate
pip3 install -r tests/requirements.txt
python3 -m pytest tests/integration


# Deploys our application if the tests passed.
sam deploy


cleanup

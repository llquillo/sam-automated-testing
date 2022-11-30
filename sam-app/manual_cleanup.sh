# Stops our local lambda server.
procInfo=`ps aux | grep sam[[:space:]]local`
IFS=' ' read -r -a procArr <<< "$procInfo"
if [ -n "${procArr[1]}" ]; then
  kill ${procArr[1]}
fi

# Stops our test-db docker container.
docker-compose -f test_db/docker-compose.yml down

#!/bin/bash
BUNDLE=ds
COMPOSE_FILE="docker-compose.yaml"
ENV_FILE="compose.env"
envs=("prod" "test" "stage" "dev" "valid")
commands=("create" "start" "stop" "remove" "recreate" restart"")
ENVIRONMENT=$1
COMMAND=$2
checkval="\<$ENVIRONMENT\>"
if [[ ! ${envs[@]} =~ $checkval ]] ; then echo "Wrong environment name"; exit; fi
checkval="\<$COMMAND\>"
if [[ ! ${commands[@]} =~ $checkval ]] ; then echo "Wrong command name"; exit; fi

start(){
    docker compose -f ./$COMPOSE_FILE --env-file ../global-env/environments/$ENVIRONMENT/env/shared.env --env-file ../global-env/environments/$ENVIRONMENT/env/proxy-map.env --env-file ../global-env/environments/$ENVIRONMENT/env/routes.env --env-file ./environments/$ENVIRONMENT/env/$ENV_FILE -p $ENVIRONMENT start
}

create() {
    docker compose -f ./$COMPOSE_FILE --env-file ../global-env/environments/$ENVIRONMENT/env/shared.env --env-file ../global-env/environments/$ENVIRONMENT/env/proxy-map.env --env-file ../global-env/environments/$ENVIRONMENT/env/routes.env --env-file ./environments/$ENVIRONMENT/env/$ENV_FILE -p $ENVIRONMENT create
    start
}

stop(){
    docker compose -f ./$COMPOSE_FILE --env-file ../global-env/environments/$ENVIRONMENT/env/shared.env --env-file ../global-env/environments/$ENVIRONMENT/env/proxy-map.env --env-file ../global-env/environments/$ENVIRONMENT/env/routes.env --env-file ./environments/$ENVIRONMENT/env/$ENV_FILE -p $ENVIRONMENT stop
}

remove(){
    stop
    docker compose -f ./$COMPOSE_FILE --env-file ../global-env/environments/$ENVIRONMENT/env/shared.env --env-file ../global-env/environments/$ENVIRONMENT/env/proxy-map.env --env-file ../global-env/environments/$ENVIRONMENT/env/routes.env --env-file ./environments/$ENVIRONMENT/env/$ENV_FILE -p $ENVIRONMENT rm
}

restart(){
    stop
    start
}

recreate(){
    remove
    create
}

case "$COMMAND" in 
    "create")
        create;;
    "start")
        start;;
    "stop")
        stop;;
    "remove")
        remove;;
    "restart")
        restart;;
    "recreate")
        recreate;;
esac

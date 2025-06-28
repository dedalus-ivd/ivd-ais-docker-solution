#!/bin/bash
BUNDLE=device_manager
COMPOSE_FILE="$BUNDLE-compose.yml"
ENV_FILE="$BUNDLE.env"
envs=("prod" "test" "stage" "dev" "valid")
commands=("create" "start" "stop" "remove" "recreate" restart"")
ENVIRONMENT=$1
COMMAND=$2
checkval="\<$ENVIRONMENT\>"
if [[ ! ${envs[@]} =~ $checkval ]] ; then echo "Wrong environment name"; exit; fi
checkval="\<$COMMAND\>"
if [[ ! ${commands[@]} =~ $checkval ]] ; then echo "Wrong command name"; exit; fi


start(){
    docker compose -f ./$COMPOSE_FILE --env-file ../global-env/environments/$ENVIRONMENT/shared.env --env-file ../global-env/environments/$ENVIRONMENT/proxy-map.env --env-file ../global-env/environments/$ENVIRONMENT/routes.env --env-file ./environments/$ENVIRONMENT/env/$ENV_FILE start
}

create() {
    docker compose -f ./$COMPOSE_FILE --env-file ../global-env/environments/$ENVIRONMENT/shared.env --env-file ../global-env/environments/$ENVIRONMENT/proxy-map.env --env-file ../global-env/environments/$ENVIRONMENT/routes.env --env-file ./environments/$ENVIRONMENT/env/$ENV_FILE create
    start
}

stop(){
    docker compose -f ./$COMPOSE_FILE --env-file ../global-env/environments/$ENVIRONMENT/shared.env --env-file ../global-env/environments/$ENVIRONMENT/proxy-map.env --env-file ../global-env/environments/$ENVIRONMENT/routes.env --env-file ./environments/$ENVIRONMENT/env/$ENV_FILE stop
}

remove(){
    stop
    docker compose -f ./$COMPOSE_FILE --env-file ../global-env/environments/$ENVIRONMENT/shared.env --env-file ../global-env/environments/$ENVIRONMENT/proxy-map.env --env-file ../global-env/environments/$ENVIRONMENT/routes.env --env-file ./environments/$ENVIRONMENT/env/$ENV_FILE rm
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
        stop;;
    "restart")
        restart;;
    "recreate")
        recreate;;
esac
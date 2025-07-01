#!/bin/bash

create() {
    docker compose -f ./docker-compose.yaml --env-file ../global-env/environments/$ENVIRONMENT/env/shared.env --env-file ./environments/$ENVIRONMENT/env/compose.env --all-resources create
}

envs=("prod" "test" "stage" "dev" "valid")
commands=("create" "remove")
ENVIRONMENT=$1
COMMAND=$2
checkval="\<$ENVIRONMENT\>"
if [[ ! ${envs[@]} =~ $checkval ]] ; then echo "Wrong environment name"; exit; fi
checkval="\<$COMMAND\>"
if [[ ! ${commands[@]} =~ $checkval ]] ; then echo "Wrong command name"; exit; fi

case "$COMMAND" in 
    "create")
        create
        ;;
    "remove")
        remove
        ;;
esac



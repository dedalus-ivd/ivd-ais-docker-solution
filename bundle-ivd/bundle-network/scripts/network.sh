#!/bin/bash

create() {
    docker compose -f ./network-compose.yml --env-file ../global-env/environments/$ENVIRONMENT/shared.env --env-file ./environments/$ENVIRONMENT/env/network.env --all-resources create
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



docker compose -f device_manager-compose.yml --env-file env/shared.env --env-file env/routes.env create
docker compose -f device_manager-compose.yml --env-file env/shared.env --env-file env/routes.env start

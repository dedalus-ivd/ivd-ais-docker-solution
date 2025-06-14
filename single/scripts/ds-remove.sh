docker compose -f ds-compose.yml --env-file env/shared.env --env-file env/routes.env stop
docker compose -f ds-compose.yml --env-file env/shared.env --env-file env/routes.env rm
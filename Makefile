mode=traefik  # traefik or nginx
rebuild:
	docker compose up -p krc$(mode) -f docker-compose-$(mode).yml \
		-d --force-recreate --build

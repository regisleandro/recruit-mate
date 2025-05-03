.PHONY: build up down logs restart shell-api shell-frontend db-setup db-migrate lint tests

# Build all containers
build:
	docker-compose build

# Start all containers
up:
	docker-compose up -d

# Stop all containers
down:
	docker-compose down

# Show logs
logs:
	docker-compose logs -f

# Restart all containers
restart:
	docker-compose restart

# Get a shell in the API container
shell-api:
	docker-compose exec api bash

# Get a shell in the frontend container
shell-frontend:
	docker-compose exec frontend sh

# Setup the database (first time only)
db-setup:
	docker-compose exec api rails db:create db:migrate db:seed

# Run database migrations
db-migrate:
	docker-compose exec api rails db:migrate

# Run linting on API
lint:
	docker-compose exec api make lint

# Run API tests
tests:
	docker-compose exec api make tests 
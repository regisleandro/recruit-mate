# RecruitMate Production Deployment

This guide provides instructions for deploying RecruitMate in production.

## Prerequisites

- Docker and Docker Compose installed on your server
- A server with sufficient resources (at least 2GB RAM recommended)
- Domain name configured (optional, for HTTPS)

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```
# Database
POSTGRES_USER=recruit_mate
POSTGRES_PASSWORD=your_strong_password
POSTGRES_DB=recruit_mate_production

# Redis
REDIS_PASSWORD=your_strong_redis_password

# Rails
SECRET_KEY_BASE=your_secret_key_base_at_least_64_characters_long
API_URL=http://your-domain.com
```

You can generate a secure SECRET_KEY_BASE with:

```bash
openssl rand -hex 64
```

## Deployment

1. Build and start the containers:

```bash
docker-compose -f docker-compose.production.yml up -d
```

2. Monitor the logs:

```bash
docker-compose -f docker-compose.production.yml logs -f
```

## SSL/TLS Setup

For production deployments, it's recommended to use HTTPS. You can:

1. Uncomment the Nginx service in `docker-compose.production.yml`
2. Configure SSL certificates in the Nginx configuration
3. Use Let's Encrypt for free certificates

## Database Backups

Set up regular backups of your PostgreSQL database:

```bash
# Backup
docker exec -t recruit-mate_db_1 pg_dump -U recruit_mate recruit_mate_production > backup_$(date +%Y-%m-%d_%H-%M-%S).sql

# Restore
cat backup_file.sql | docker exec -i recruit-mate_db_1 psql -U recruit_mate -d recruit_mate_production
```

## Scaling

For higher traffic scenarios:
- Consider using a production-grade PostgreSQL server
- Set up a load balancer in front of multiple Rails instances
- Use a dedicated Redis server or cluster

## Troubleshooting

- Check container logs: `docker-compose -f docker-compose.production.yml logs [service_name]`
- Access Rails console: `docker-compose -f docker-compose.production.yml exec api rails console`
- Check database connection: `docker-compose -f docker-compose.production.yml exec db psql -U recruit_mate -d recruit_mate_production` 
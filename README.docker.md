# Docker Development Environment for MONARC FrontOffice

This guide explains how to set up a local development environment for MONARC FrontOffice using Docker.

## Prerequisites

- Docker Engine 20.10 or later
- Docker Compose V2 (comes with Docker Desktop)
- At least 8GB of RAM available for Docker
- At least 20GB of free disk space

## Quick Start

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone https://github.com/monarc-project/MonarcAppFO
   cd MonarcAppFO
   ```

2. **Copy the environment file**:
   ```bash
   cp .env.dev .env
   ```

3. **Customize environment variables** (optional):
   Edit `.env` file to change default passwords and configuration:
   ```bash
   # Generate a secure secret key for stats service
   openssl rand -hex 32
   # Update STATS_SECRET_KEY in .env with the generated value
   ```

4. **Start the development environment**:
   ```bash
   docker-compose -f docker-compose.dev.yml up --build
   ```

   The first run will take several minutes as it:
   - Builds the Docker images
   - Installs all dependencies (PHP, Node.js, Python)
   - Clones frontend repositories
   - Initializes databases
   - Sets up the stats service
   - Creates the initial admin user

5. **Access the application**:
   - MONARC FrontOffice: http://localhost:5001
   - Stats Service: http://localhost:5005
   - MailCatcher (email testing): http://localhost:1080

6. **(Optional) Configure Stats API Key**:
   The stats service generates an API key on first run. To retrieve it:
   ```bash
   # Check the stats service logs for the API key
   docker-compose -f docker-compose.dev.yml logs stats-service | grep "Token:"
   
   # Or create a new client and get the key
   docker exec -it monarc-fo-stats poetry run flask client_create --name monarc
   
   # Update the .env file with the API key and restart the monarc service
   docker-compose -f docker-compose.dev.yml restart monarc
   ```

7. **Login credentials**:
   - Username: `admin@admin.localhost`
   - Password: `admin`

## Services

The development environment includes the following services:

| Service | Description | Port | Container Name |
|---------|-------------|------|----------------|
| monarc | Main FrontOffice application (PHP/Apache) | 5001 | monarc-fo-app |
| db | MariaDB database | 3306 | monarc-fo-db |
| postgres | PostgreSQL database (for stats) | 5432 | monarc-fo-postgres |
| stats-service | MONARC Statistics Service | 5005 | monarc-fo-stats |
| mailcatcher | Email testing tool | 1080 (web), 1025 (SMTP) | monarc-fo-mailcatcher |

## Development Workflow

### Live Code Editing

The application source code is mounted as a volume, so changes you make on your host machine will be immediately reflected in the container. After making changes:

1. **PHP/Backend changes**: Apache automatically reloads modified files
2. **Frontend changes**: You may need to rebuild the frontend:
   ```bash
   docker exec -it monarc-fo-app bash
   cd /var/www/html/monarc
   ./scripts/update-all.sh -d
   ```

### Accessing the Container

To access the MONARC application container:
```bash
docker exec -it monarc-fo-app bash
```

To access the stats service container:
```bash
docker exec -it monarc-fo-stats bash
```

### Database Access

Connect to MariaDB:
```bash
docker exec -it monarc-fo-db mysql -usqlmonarcuser -psqlmonarcuser monarc_common
```

Connect to PostgreSQL:
```bash
docker exec -it monarc-fo-postgres psql -U sqlmonarcuser -d statsservice
```

### Viewing Logs

View logs for all services:
```bash
docker-compose -f docker-compose.dev.yml logs -f
```

View logs for a specific service:
```bash
docker-compose -f docker-compose.dev.yml logs -f monarc
docker-compose -f docker-compose.dev.yml logs -f stats-service
```

### Restarting Services

Restart all services:
```bash
docker-compose -f docker-compose.dev.yml restart
```

Restart a specific service:
```bash
docker-compose -f docker-compose.dev.yml restart monarc
```

### Stopping the Environment

Stop all services (keeps data):
```bash
docker-compose -f docker-compose.dev.yml stop
```

Stop and remove containers (keeps volumes/data):
```bash
docker-compose -f docker-compose.dev.yml down
```

Stop and remove everything including data:
```bash
docker-compose -f docker-compose.dev.yml down -v
```

## Common Tasks

### Resetting the Database

To completely reset the databases:
```bash
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up --build
```

### Installing New PHP Dependencies

```bash
docker exec -it monarc-fo-app bash
composer require package/name
```

### Installing New Node Dependencies

```bash
docker exec -it monarc-fo-app bash
cd node_modules/ng_client  # or ng_anr
npm install package-name
```

### Running Database Migrations

```bash
docker exec -it monarc-fo-app bash
php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/FrontOffice/migrations/phinx.php
```

### Creating Database Seeds

```bash
docker exec -it monarc-fo-app bash
php ./bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php
```

### Rebuilding Frontend

```bash
docker exec -it monarc-fo-app bash
cd /var/www/html/monarc
./scripts/update-all.sh -d
```

## Debugging

### Xdebug Configuration

Xdebug is pre-configured in the development environment. To use it:

1. Configure your IDE to listen on port 9003
2. Set the IDE key to `IDEKEY`
3. Start debugging in your IDE
4. Trigger a request to the application

For PhpStorm:
- Go to Settings → PHP → Debug
- Set Xdebug port to 9003
- Enable "Can accept external connections"
- Set the path mappings: `/var/www/html/monarc` → your local project path

### Checking Service Health

```bash
# Check if all services are running
docker-compose -f docker-compose.dev.yml ps

# Check specific service health
docker-compose -f docker-compose.dev.yml ps monarc
```

## Troubleshooting

### Port Conflicts

If you get port conflicts, you can change the ports in the `docker-compose.dev.yml` file:
```yaml
ports:
  - "5001:80"  # Change 5001 to another available port
```

### Permission Issues

If you encounter permission issues with mounted volumes:
```bash
docker exec -it monarc-fo-app bash
chown -R www-data:www-data /var/www/html/monarc/data
chmod -R 775 /var/www/html/monarc/data
```

### Database Connection Issues

Check if the database is healthy:
```bash
docker-compose -f docker-compose.dev.yml ps db
```

If needed, restart the database:
```bash
docker-compose -f docker-compose.dev.yml restart db
```

### Stats Service Issues

Check stats service logs:
```bash
docker-compose -f docker-compose.dev.yml logs stats-service
```

Restart the stats service:
```bash
docker-compose -f docker-compose.dev.yml restart stats-service
```

### Rebuilding from Scratch

If something goes wrong and you want to start fresh:
```bash
# Stop everything
docker-compose -f docker-compose.dev.yml down -v

# Remove all related containers, images, and volumes
docker system prune -a

# Rebuild and start
docker-compose -f docker-compose.dev.yml up --build
```

## Performance Optimization

For better performance on macOS and Windows:

1. **Use Docker volume mounts for dependencies**: The compose file already uses named volumes for `vendor` and `node_modules` to improve performance.

2. **Allocate more resources**: In Docker Desktop settings, increase:
   - CPUs: 4 or more
   - Memory: 8GB or more
   - Swap: 2GB or more

3. **Enable caching**: The Dockerfile uses apt cache and composer optimizations.

## Comparison with Vagrant

| Feature | Docker | Vagrant |
|---------|--------|---------|
| Startup time | Fast (~2-3 min) | Slow (~10-15 min) |
| Resource usage | Lower | Higher |
| Isolation | Container-level | VM-level |
| Portability | Excellent | Good |
| Live code reload | Yes | Yes |
| Learning curve | Moderate | Low |

## Environment Variables Reference

All environment variables are defined in the `.env` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `DBPASSWORD_ADMIN` | MariaDB root password | `root` |
| `DBNAME_COMMON` | Common database name | `monarc_common` |
| `DBNAME_CLI` | CLI database name | `monarc_cli` |
| `DBUSER_MONARC` | Database user | `sqlmonarcuser` |
| `DBPASSWORD_MONARC` | Database password | `sqlmonarcuser` |
| `STATS_HOST` | Stats service host | `0.0.0.0` |
| `STATS_PORT` | Stats service port | `5005` |
| `STATS_DB_NAME` | Stats database name | `statsservice` |
| `STATS_DB_USER` | Stats database user | `sqlmonarcuser` |
| `STATS_DB_PASSWORD` | Stats database password | `sqlmonarcuser` |
| `STATS_SECRET_KEY` | Stats service secret key | `changeme_generate_random_secret_key_for_production` |

## Security Notes

⚠️ **Important**: The default credentials provided are for development only. Never use these in production!

For production deployments:
1. Change all default passwords
2. Generate a secure `STATS_SECRET_KEY` using `openssl rand -hex 32`
3. Use proper SSL/TLS certificates
4. Follow security best practices

## Additional Resources

- [MONARC Website](https://www.monarc.lu)
- [MONARC Documentation](https://www.monarc.lu/documentation)
- [GitHub Repository](https://github.com/monarc-project/MonarcAppFO)
- [MonarcAppBO (BackOffice)](https://github.com/monarc-project/MonarcAppBO)

## Getting Help

If you encounter issues:

1. Check the [troubleshooting section](#troubleshooting)
2. Review the logs: `docker-compose -f docker-compose.dev.yml logs`
3. Open an issue on [GitHub](https://github.com/monarc-project/MonarcAppFO/issues)
4. Join the MONARC community discussions

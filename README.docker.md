# Docker Development Environment for MONARC FrontOffice

This guide explains how to set up a local development environment for MONARC FrontOffice using Docker.

## Prerequisites

- Docker Engine 20.10 or later
- Docker Compose V2 (comes with Docker Desktop)
- At least 8GB of RAM available for Docker
- At least 20GB of free disk space
- A sibling checkout of `zm-core`, `zm-client`, `ng-anr`, and `ng-client`

The development Compose configuration bind-mounts those four repositories. Keep
them beside `MonarcAppFO`; Docker is configured to fail rather than silently
create empty directories when one is missing:

```text
parent-directory/
├── MonarcAppFO/
├── zm-core/
├── zm-client/
├── ng-anr/
└── ng-client/
```

## Quick Start

### Option 1: Using the Makefile (Recommended)

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone https://github.com/monarc-project/MonarcAppFO
   cd MonarcAppFO
   ```

2. **Start the development environment**:
   ```bash
   make start
   ```
   
   This will automatically:
   - Create `.env` file from `.env.dev` if it doesn't exist
   - Build and start all services
   - Display access URLs
   
   The first run will take several minutes as it:
   - Builds the Docker images
   - Installs all dependencies (PHP, Node.js, Python)
   - Clones frontend repositories
   - Initializes databases
   - Sets up the stats service
   - Creates the initial admin user

3. **Access the application**:
   - MONARC FrontOffice: http://localhost:5001
   - Stats Service: http://localhost:5005
   - MailCatcher (email testing): http://localhost:1080

4. **Login credentials**:
   - Username: `admin@admin.localhost`
   - Password: `admin`

### Option 2: Using Docker Compose Directly

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
   docker compose -f docker-compose.dev.yml up --build
   ```

5. **Access the application**:
   - MONARC FrontOffice: http://localhost:5001
   - Stats Service: http://localhost:5005
   - MailCatcher (email testing): http://localhost:1080

6. **(Optional) Configure Stats API Key**:
   The stats service generates an API key on first run. To retrieve it:
   ```bash
   # Using Makefile
   make stats-key
   
   # Or manually check logs
   docker compose -f docker-compose.dev.yml logs stats-service | grep "Token:"
   
   # Or create a new client and get the key
   docker compose -f docker-compose.dev.yml exec stats-service poetry run flask client_create --name monarc
   
   # Update STATS_API_KEY in .env and recreate the application service
   docker compose -f docker-compose.dev.yml up -d --no-deps monarcfoapp
   ```

7. **Login credentials**:
   - Username: `admin@admin.localhost`
   - Password: `admin`

## Services

The development environment includes the following services:

| Service | Description | Host port | Container port | Override |
|---------|-------------|-----------|----------------|----------|
| monarcfoapp | Main FrontOffice application (PHP/Apache) | 5001 | 80 | `MONARC_FO_APP_PORT` |
| fodb | MariaDB database | 3307 | 3306 | `MONARC_FO_DB_PORT` |
| postgres | PostgreSQL database (for stats) | 5432 | 5432 | `MONARC_FO_POSTGRES_PORT` |
| stats-service | MONARC Statistics Service | 5005 | 5005 | `MONARC_FO_STATS_PORT` |
| mailcatcher | Email testing web interface | 1080 | 1080 | `MONARC_FO_MAIL_HTTP_PORT` |
| mailcatcher | Email testing SMTP server | 1025 | 1025 | `MONARC_FO_MAIL_SMTP_PORT` |

These defaults are for one FrontOffice stack. Change the host port overrides in
`.env` when running another stack. Services communicate through their Docker
service names and container ports. An existing `.env` keeps its configured values
when `.env.dev` changes.

## Development Workflow

### Makefile Commands

The Makefile provides convenient commands for managing the development environment.
Use `ENV=<name>` to select `docker compose.<name>.yml` (default: `dev`).

```bash
make start         # Start all services
make local-repos   # Start and use mounted sibling repositories
make remote-repos  # Restore release packages and cloned frontends
make repo-status   # Show the active source mode
make stop          # Stop all services
make restart       # Restart all services
make logs          # View logs from all services
make logs-app      # View logs from MONARC application
make logs-stats    # View logs from stats service
make shell         # Open a shell in the MONARC container
make shell-stats   # Open a shell in the stats service container
make db            # Open MySQL client
make status        # Show status of all services
make stats-key     # Show the stats API key
make reset         # Reset everything (removes all data)
```

### Live Code Editing

Run frontend installation and updates inside the container, which provides
Node.js 16.x for the locked frontend dependencies:

```bash
make shell
# Inside the container:
./scripts/update-all.sh -d
```

Host builds also require Node.js 16.x. On Apple Silicon, use an ARM64 Node
runtime with ARM64 developer tools. Dependencies containing native binaries
must be installed again when switching between the host and container.

The application source code is mounted as a volume, so changes you make on your host machine will be immediately reflected in the container. After making changes:

1. **PHP/Backend changes**: Apache automatically reloads modified files
2. **Frontend changes**: You may need to rebuild the frontend:
   ```bash
   docker compose -f docker-compose.dev.yml exec monarcfoapp bash
   cd /var/www/html/monarc
   ./scripts/update-all.sh -d
   ```

### Developing sibling repositories

The sibling repositories are mounted into the container but are not used until
you switch the application to local sources. This preserves the normal
release-package startup path while making changes in all four sibling
repositories available for development.

```bash
make local-repos
```

This verifies the checkout layout, starts the environment, makes Composer use
symlinked `zm-core` and `zm-client` packages, and links the two AngularJS
repositories into `node_modules`. It then rebuilds the linked frontend assets.

Use these commands to inspect or revert the source mode:

```bash
make repo-status
make remote-repos
```

`make remote-repos` restores the release Composer packages and GitHub frontend
clones. Switching source mode updates Composer metadata and dependencies, so
review the `MonarcAppFO` working tree before committing.

### Accessing the Container

Using Makefile:
```bash
make shell        # MONARC application
make shell-stats  # Stats service
```

Or directly with docker:
```bash
docker compose -f docker-compose.dev.yml exec monarcfoapp bash      # MONARC application
docker compose -f docker-compose.dev.yml exec stats-service bash    # Stats service
```

### Database Access

Using Makefile:
```bash
make db  # Connect to MariaDB
```

Or directly with docker:
```bash
# Connect to MariaDB
docker compose -f docker-compose.dev.yml exec fodb sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -u"$MYSQL_USER" "$MYSQL_DATABASE"'

# Connect to PostgreSQL
docker compose -f docker-compose.dev.yml exec postgres sh -c 'exec psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

### Viewing Logs

Using Makefile:
```bash
make logs          # All services
make logs-app      # MONARC application only
make logs-stats    # Stats service only
```

Or directly with docker compose:
```bash
# View logs for all services
docker compose -f docker-compose.dev.yml logs -f

# View logs for a specific service
docker compose -f docker-compose.dev.yml logs -f monarcfoapp
docker compose -f docker-compose.dev.yml logs -f stats-service
```

### Restarting Services

Using Makefile:
```bash
make restart  # Restart all services
```

Or directly with docker compose:
```bash
# Restart all services
docker compose -f docker-compose.dev.yml restart

# Restart a specific service
docker compose -f docker-compose.dev.yml restart monarcfoapp
```

### Stopping the Environment

Using Makefile:
```bash
make stop   # Stop all services (keeps data)
make reset  # Stop and remove everything including data
```

Or directly with docker compose:
```bash
# Stop all services (keeps data)
docker compose -f docker-compose.dev.yml stop

# Stop and remove containers (keeps volumes/data)
docker compose -f docker-compose.dev.yml down

# Stop and remove everything including data
docker compose -f docker-compose.dev.yml down -v
```

## Common Tasks

### Using BackOffice monarc_common

To reuse the BackOffice `monarc_common` database:

1. Set `USE_BO_COMMON=1` in `.env`.
2. Point `DBHOST` to the BackOffice MariaDB host (for example, `bodb` on a shared Docker network).
3. Ensure the BackOffice database already has `monarc_common` and grants for `DBUSER_MONARC`.

### Shared Docker Network

To connect FrontOffice and BackOffice containers, use a shared external network:

1. Create the network once: `docker network create monarc-network`
2. Set `MONARC_NETWORK_NAME=monarc-network` in both projects' `.env` files.
3. Ensure the BackOffice compose file also uses the same external network name.

### Resetting the Database

To completely reset the databases:
```bash
docker compose -f docker-compose.dev.yml down -v
docker compose -f docker-compose.dev.yml up --build
```

### Installing New PHP Dependencies

```bash
docker compose -f docker-compose.dev.yml exec monarcfoapp bash
composer require package/name
```

### Installing New Node Dependencies

```bash
docker compose -f docker-compose.dev.yml exec monarcfoapp bash
cd node_modules/ng_client  # or ng_anr
npm install package-name
```

### Running Database Migrations

```bash
docker compose -f docker-compose.dev.yml exec monarcfoapp bash
php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/FrontOffice/migrations/phinx.php
```

### Creating Database Seeds

```bash
docker compose -f docker-compose.dev.yml exec monarcfoapp bash
php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php
```

### Rebuilding Frontend

```bash
docker compose -f docker-compose.dev.yml exec monarcfoapp bash
cd /var/www/html/monarc
./scripts/update-all.sh -d
```

## Debugging

### Xdebug Configuration

Xdebug is enabled by default in the development image. To disable it, set
`XDEBUG_ENABLED=0` in `.env` and rebuild the image (for example, `make start`).
You can also tune the connection behavior via `.env`:
`XDEBUG_START_WITH_REQUEST`, `XDEBUG_CLIENT_HOST`, and `XDEBUG_CLIENT_PORT`.

When enabled, Xdebug is pre-configured. To use it:

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
docker compose -f docker-compose.dev.yml ps

# Check specific service health
docker compose -f docker-compose.dev.yml ps monarcfoapp
```

## Troubleshooting

### Port Conflicts

If you get port conflicts, you can change the ports in the `docker-compose.dev.yml` file:
```yaml
ports:
  - "5001:80"  # Change 5001 to another available port
```

To change the MariaDB host port without editing the compose file, set
`MONARC_FO_DB_PORT` in `.env` (default: `3307`).

### Permission Issues

If you encounter permission issues with mounted volumes:
```bash
docker compose -f docker-compose.dev.yml exec monarcfoapp bash
chown -R www-data:www-data /var/www/html/monarc/data
chmod -R 775 /var/www/html/monarc/data
```

### Database Connection Issues

Check if the database is healthy:
```bash
docker compose -f docker-compose.dev.yml ps fodb
```

If needed, restart the database:
```bash
docker compose -f docker-compose.dev.yml restart fodb
```

### Stats Service Issues

Check stats service logs:
```bash
docker compose -f docker-compose.dev.yml logs stats-service
```

Restart the stats service:
```bash
docker compose -f docker-compose.dev.yml restart stats-service
```

### Rebuilding from Scratch

If something goes wrong and you want to start fresh:
```bash
# Stop everything
docker compose -f docker-compose.dev.yml down -v

# Remove all related containers, images, and volumes
docker system prune -a

# Rebuild and start
docker compose -f docker-compose.dev.yml up --build
```

## Performance Optimization

For better performance on macOS and Windows:

1. **Use Docker volume mounts for dependencies**: The compose file already uses named volumes for `vendor` and `node_modules` to improve performance.

2. **Allocate more resources**: In Docker Desktop settings, increase:
   - CPUs: 4 or more
   - Memory: 8GB or more
   - Swap: 2GB or more

3. **Enable caching**: `Dockerfile.dev` uses apt cache and composer optimizations.

## Comparison with Vagrant

| Feature | Docker | Vagrant |
|---------|--------|---------|
| Startup time | Fast (~2-3 min) | Slow (~10-15 min) |
| Resource usage | Lower | Higher |
| Isolation | Container-level | VM-level |
| Portability | Excellent | Good |
| Live code reload | Yes | Yes |
| Learning curve | Moderate | Low |

### Public URL for password-reset links

`PUBLIC_HOST` is the externally reachable absolute http(s) URL for this instance,
including any public port and installation path. Development defaults to
`http://localhost:5001` and follows `MONARC_FO_APP_PORT` in `.env.dev`.
Override it for a reverse proxy or server, for example
`PUBLIC_HOST=https://monarc.example.org`. Credentials, query strings and URL
fragments are rejected. The value is never taken from the request `Host` header.

Fresh Docker initialization requires a valid `PUBLIC_HOST` before installing
packages or changing databases. Release images have no implicit public URL;
provide it explicitly. Existing initialized containers keep their existing
`config/autoload/local.php`: add/update its top-level `publicHost` manually,
clear that application's generated configuration cache and restart it. Changing
`.env` alone does not rewrite an initialized application's local configuration.

## Building a release image

Release images use a clean checkout with the locked PHP packages, compiled
frontend bundles and translations already assembled. On a build machine with
PHP 8.4, Node 16 and the documented build dependencies, run in that clean checkout:

```bash
bash scripts/prepare-release.sh
docker build --file Dockerfile.release --build-arg CAPTCHA_ENABLED=true --tag monarc-fo:local-release .
```

`Dockerfile.release.dockerignore` supplies the release inclusion rules and takes
precedence over the development `.dockerignore`. It excludes local databases,
configuration, caches and macOS metadata while retaining required assets and
translations. No separate copied build context is needed.

The resulting image contains the PHP runtime, database clients and LibreOffice.
Node/npm, Composer, Grunt and compilers remain on the build machine. Deploy a new
image for code updates; do not run `update-all.sh` inside a release container.

## GHCR application images

The release and stage publishers use `Dockerfile.ghcr` with the same prepared
application sources. This separate build copies PHP and its runtime libraries
into Debian slim, leaving the PHP base image's compiler layers out of GHCR.
FrontOffice includes LibreOffice for document conversion.
Database clients remain available for initialization and backups. The archive
release, `Dockerfile.release` and development builds use their existing paths.

To build the GHCR variant locally after `scripts/prepare-release.sh`:

```bash
docker build --file Dockerfile.ghcr --build-arg CAPTCHA_ENABLED=true --tag monarc-fo:local-ghcr .
```

`Dockerfile.ghcr.dockerignore` applies the same inclusion rules as the release build.

## Environment Variables Reference

The development Docker entrypoint copies `docker/smtp.local.php` into the
application's autoload configuration on startup, so fresh and initialized installations send mail to
`mailcatcher:1025`. View captured mail at `http://localhost:1080` by default
(`MONARC_FO_MAIL_HTTP_PORT`). The SMTP destination uses the container port, not
the published `MONARC_FO_MAIL_SMTP_PORT`.

To reuse a MailCatcher running in another Docker stack at `http://localhost:1080`
with SMTP published on port `8825`, set these overrides in `.env`:

```dotenv
SMTP_HOST=host.docker.internal
SMTP_PORT=8825
```

Recreate the application container after changing these settings. In development,
the generated configuration overrides `smtpOptions` from `config/autoload/local.php`.

All environment variables are defined in the `.env` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `DBHOST` | MariaDB host for MONARC | `fodb` |
| `MONARC_FO_APP_PORT` | FrontOffice host port | `5001` |
| `MONARC_FO_DB_PORT` | MariaDB host port | `3307` |
| `MONARC_FO_POSTGRES_PORT` | PostgreSQL host port | `5432` |
| `MONARC_FO_STATS_PORT` | Statistics service host port | `5005` |
| `MONARC_FO_MAIL_HTTP_PORT` | MailCatcher web host port | `1080` |
| `MONARC_FO_MAIL_SMTP_PORT` | MailCatcher SMTP host port | `1025` |
| `DBPASSWORD_ADMIN` | MariaDB root password | `root` |
| `DBNAME_COMMON` | Common database name | `monarc_common` |
| `DBNAME_CLI` | CLI database name | `monarc_cli` |
| `DBUSER_MONARC` | Database user | `sqlmonarcuser` |
| `DBPASSWORD_MONARC` | Database password | `sqlmonarcuser` |
| `PUBLIC_HOST` | Public base URL for password-reset links; required on first initialization | `http://localhost:5001` (dev) |
| `USE_BO_COMMON` | Use BackOffice `monarc_common` (`1/0`, `true/false`, `yes/no`) | `0` |
| `SMTP_HOST` | Development SMTP server | `mailcatcher` |
| `SMTP_PORT` | Development SMTP server port | `1025` |
| `MONARC_NETWORK_NAME` | Shared Docker network name | `monarc-network` |
| `STATS_HOST` | Stats service host | `0.0.0.0` |
| `STATS_PORT` | Stats service port | `5005` |
| `STATS_DB_NAME` | Stats database name | `statsservice` |
| `STATS_DB_USER` | Stats database user | `sqlmonarcuser` |
| `STATS_DB_PASSWORD` | Stats database password | `sqlmonarcuser` |
| `STATS_SECRET_KEY` | Stats service secret key | `changeme_generate_random_secret_key_for_production` |
| `STATS_API_KEY` | API key used by MONARC to access the statistics service | empty |
| `STATS_API_BASE_URL` | Statistics service URL used by MONARC | `http://stats-service:5005` |
| `PDF_CONVERTER_BINARY` | LibreOffice binary used for deliverable PDF conversion | `/usr/bin/soffice` |
| `CAPTCHA_ENABLED` | Enable CAPTCHA after repeated failed logins | `false` in dev/stage; `true` in production releases |
| `XDEBUG_ENABLED` | Enable Xdebug in the build (`1/0`, `true/false`, `yes/no`) | `1` |
| `XDEBUG_MODE` | Xdebug modes (`debug`, `develop`, etc.) | `debug` |
| `XDEBUG_START_WITH_REQUEST` | Start mode (`trigger` or `yes`) | `trigger` |
| `XDEBUG_CLIENT_HOST` | Host IDE address | `host.docker.internal` |
| `XDEBUG_CLIENT_PORT` | IDE port | `9003` |
| `XDEBUG_IDEKEY` | IDE key | `IDEKEY` |
| `XDEBUG_DISCOVER_CLIENT_HOST` | Auto-detect client host (`1/0`) | `0` |

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
2. Review the logs: `docker compose -f docker-compose.dev.yml logs`
3. Open an issue on [GitHub](https://github.com/monarc-project/MonarcAppFO/issues)
4. Join the community discussions on [GitHub](https://github.com/monarc-project/MonarcAppFO/discussions)

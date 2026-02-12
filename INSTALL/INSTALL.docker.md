# Docker Installation Guide for MONARC FrontOffice

This document provides installation instructions for setting up MONARC FrontOffice using Docker for development purposes.

## Quick Installation

```bash
# Clone the repository
git clone https://github.com/monarc-project/MonarcAppFO
cd MonarcAppFO

# Start with the Makefile (recommended)
make start

# Or use docker compose directly
cp .env.dev .env
docker compose -f docker-compose.dev.yml up -d --build
```

## What Gets Installed

The Docker setup includes:

1. **MONARC FrontOffice Application**
   - Ubuntu 22.04 base
   - PHP 8.1 with all required extensions
   - Apache web server
   - Composer for PHP dependencies
   - Node.js for frontend
   - All MONARC modules and dependencies

2. **MariaDB 10.11**
   - Database for MONARC application data
   - Pre-configured with proper character sets

3. **PostgreSQL 15**
   - Database for the statistics service

4. **Stats Service**
   - Python/Flask application
   - Poetry for dependency management
   - Integrated with MONARC FrontOffice

5. **MailCatcher**
   - Email testing interface
   - SMTP server for development

## First Time Setup

When you start the environment for the first time:

1. Docker images will be built (5-10 minutes)
2. Dependencies will be installed automatically
3. Databases will be created and initialized
4. Frontend repositories will be cloned and built
5. Initial admin user will be created

## Access URLs

After startup, access the application at:

- **MONARC FrontOffice**: http://localhost:5001
- **Stats Service**: http://localhost:5005
- **MailCatcher**: http://localhost:1080

## Default Credentials

- **Username**: admin@admin.localhost
- **Password**: admin

⚠️ **Security Warning**: Change these credentials before deploying to production!

## System Requirements

- Docker Engine 20.10 or later
- Docker Compose V2
- At least 8GB RAM available for Docker
- At least 20GB free disk space
- Linux, macOS, or Windows with WSL2

## Configuration

Environment variables are defined in the `.env` file (copied from `.env.dev`):

- Database credentials
- Service ports
- Secret keys

You can customize these before starting the environment.

## Troubleshooting

### Port Conflicts

If ports 5001, 5005, 3307, 5432, or 1080 are already in use:

1. Edit `docker-compose.dev.yml`
2. Change the host port (left side of the port mapping)
3. Example: Change `"5001:80"` to `"8001:80"`

You can also change the MariaDB host port by setting `DBPORT_HOST` in `.env`.

### Permission Issues

If you encounter permission errors:

```bash
docker exec -it monarc-fo-app bash
chown -R www-data:www-data /var/www/html/monarc/data
chmod -R 775 /var/www/html/monarc/data
```

### Service Not Starting

Check the logs:

```bash
make logs
# or
docker compose -f docker-compose.dev.yml logs
```

### Reset Everything

To start completely fresh:

```bash
make reset
# or
docker compose -f docker-compose.dev.yml down -v
```

## Common Tasks

### View Logs
```bash
make logs
```

### Access Container Shell
```bash
make shell
```

### Access Database
```bash
make db
```

### Stop Services
```bash
make stop
```

### Restart Services
```bash
make restart
```

## Comparison with Other Installation Methods

| Method | Complexity | Time | Best For |
|--------|-----------|------|----------|
| Docker | Low | Fast (2-5 min startup) | Development |
| Vagrant | Medium | Slow (10-15 min startup) | Development |
| Manual | High | Slow (30+ min) | Production |
| VM | Low | Medium | Testing |

## Next Steps

After installation:

1. Read the [full Docker documentation](README.docker.md)
2. Review the [MONARC documentation](https://www.monarc.lu/documentation)
3. Configure the stats API key (optional)
4. Start developing!

## Getting Help

- **Documentation**: [README.docker.md](README.docker.md)
- **MONARC Website**: https://www.monarc.lu
- **GitHub Issues**: https://github.com/monarc-project/MonarcAppFO/issues
- **Community**: https://www.monarc.lu/community

## License

This project is licensed under the GNU Affero General Public License version 3.
See [LICENSE](LICENSE) for details.

# Linked FrontOffice and BackOffice installation on Ubuntu 26.04

Install one linked FO/BO pair manually on a fresh Ubuntu 26.04 server. The two
applications share one common database and each has its own office database.
Install and migrate BO first, then FO; initialize common data only once, from BO.

For a standalone application, use the FrontOffice
[Ubuntu 26.04 guide](INSTALL.ubuntu2604.md) or the
[BackOffice guide](https://github.com/monarc-project/MonarcAppBO/blob/master/INSTALL/INSTALL.ubuntu2604.md).
For the separate automation and manual-versus-Ansible comparison, use the
[Ansible guide](INSTALL.ubuntu2604-ansible.md).

## 1. Choose names

Run the shell examples in Bash. Start a dedicated installation shell and enable
failure handling before continuing:

```bash
bash
```

Inside that shell:

```bash
set -euo pipefail
```

Keep this shell open for the installation. If a command fails, resolve the error
before continuing; start Bash and enable these options again after reconnecting.
Perform initialization from a private/admin-only environment until the default
administrator password has been changed.

Replace these example domains with DNS names pointing to your server:

| Application | Domain | Application directory | Database user | Common database | Office database |
|---|---|---|---|---|---|
| BO | `bo-manual.example.com` | `/var/lib/monarc/manual-bo` | `manual_bo` | `manual_common` | `manual_master` |
| FO | `fo-manual.example.com` | `/var/lib/monarc/manual-fo` | `manual_fo` | `manual_common` | `manual_cli` |

Both Apache virtual hosts use HTTPS port 443. Keep database listeners local.
Each application has separate writable data, caches, uploads and credentials.
They share the OS and Apache's `www-data` identity; use separate VMs or containers
when isolation between mutually untrusted applications is required.

## 2. Prepare the release artifacts on a build machine

Use the exact approved release/candidate for **each application**, with its
committed Composer lock and frontend references. An old application's “latest”
archive does not test the pending release changes merely because newer backend
packages have been published.

The target server will receive assembled archives containing `vendor`, frontend
modules, resource links, translations and fonts. It will not need Node.js,
Grunt or native frontend build dependencies. The legacy build currently uses
Node 16.20.2; keep that environment on the build machine.

For each application, start from its reviewed release checkout. The example
below is for FO; for BO use its checkout and `Dockerfile` instead of
`Dockerfile.dev`:

```bash
# On the build machine, from MonarcAppFO:
set -euo pipefail
docker build -f Dockerfile.dev -t monarc-fo-builder .
build_dir=$(mktemp -d)
tar --exclude=.git --exclude=vendor --exclude=node_modules \
    --exclude='.env*' --exclude='*.local.php' --exclude='config/autoload/local.php' \
    --exclude=.docker-initialized --exclude=.docker-release-context \
    --exclude=.docker-stage-context --exclude='./data' --exclude='./module/Monarc' \
    --exclude='./public/js' --exclude='./public/css' --exclude='./public/img' \
    --exclude='./public/flags' --exclude='./public/views' --exclude='./public/captcha' \
    -cf - . | tar -xf - -C "$build_dir"
mkdir -p "$build_dir/data"
cp -a data/fonts "$build_dir/data/fonts"
test -f "$build_dir/data/fonts/arial.ttf"
docker run --rm --entrypoint bash \
    --user "$(id -u):$(id -g)" \
    -e COMPOSER_HOME=/tmp/composer -e npm_config_cache=/tmp/npm \
    --mount "type=bind,src=$build_dir,dst=/var/www/html/monarc" \
    monarc-fo-builder -lc 'bash scripts/prepare-release.sh && composer audit --locked --no-dev --abandoned=report'
# Write the archive outside the directory being archived:
tar --exclude=.git --exclude=.github -czf /tmp/monarc-fo-candidate.tar.gz -C "$build_dir" .
```

Build BO equivalently, naming its image `monarc-bo-builder` and archive
`/tmp/monarc-bo-candidate.tar.gz`. Use clean source without local uploads,
configuration, backups or other private files; inspect the archive contents
before transferring it. The copy excludes runtime data and generated module links;
only the packaged fonts are retained from `data`. Record the reviewed source
commits with the artifacts.

```bash
cd /tmp
shasum -a 256 monarc-fo-candidate.tar.gz monarc-bo-candidate.tar.gz > MONARC-SHA256SUMS
scp monarc-fo-candidate.tar.gz monarc-bo-candidate.tar.gz MONARC-SHA256SUMS deploy@SERVER:/tmp/
```

Here `deploy` is your existing SSH/sudo user, and `SERVER` is the server's SSH
name. A published assembled release archive can replace this build step.

## 3. Install server packages

Run on the Ubuntu server:

```bash
. /etc/os-release
test "$ID" = ubuntu && test "$VERSION_ID" = 26.04
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y apache2 mariadb-server mariadb-client \
    ca-certificates curl git gettext jq unzip zip locales rsync \
    libreoffice-writer fonts-liberation gsfonts \
    certbot python3-certbot-apache
sudo localedef -i en_US -f UTF-8 en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

Reboot first if the upgrade requires it. `libreoffice-writer` provides
`/usr/bin/soffice` for PDF deliveries. No frontend build runtime, Xdebug or
MailCatcher is required on the server when installing an assembled release.

Ubuntu 26.04 defaults to PHP 8.5, while these applications require
**PHP >=8.4.28 and <8.5**. Configure the maintainer's signed repository using the
[official Sury instructions](https://packages.sury.org/php/README.txt):

```bash
php_keyring=$(mktemp)
curl -fsSL https://packages.sury.org/debsuryorg-archive-keyring.deb -o "$php_keyring"
sudo dpkg -i "$php_keyring"
rm -f "$php_keyring"
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ resolute main' \
    | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
sudo apt-get install -y libapache2-mod-php8.4 php8.4-cli php8.4-common \
    php8.4-mysql php8.4-zip php8.4-gd php8.4-mbstring php8.4-curl \
    php8.4-xml php8.4-bcmath php8.4-intl php8.4-imagick php8.4-opcache
sudo update-alternatives --set php /usr/bin/php8.4
php8.4 -r 'exit(PHP_VERSION_ID >= 80428 && PHP_VERSION_ID < 80500 ? 0 : 1);'
php8.4 --version
php8.4 -r '$required = ["bcmath", "curl", "dom", "gd", "gettext", "iconv", "intl", "mbstring", "openssl", "pdo_mysql", "xml", "zip", "imagick", "Zend OPcache"]; $missing = array_values(array_filter($required, static fn ($name) => !extension_loaded($name))); if ($missing) { fwrite(STDERR, "Missing PHP extensions: " . implode(", ", $missing) . PHP_EOL); exit(1); } echo "Required PHP extensions loaded", PHP_EOL;'
```

Do not install the unversioned `php` metapackage or use `ppa:ondrej/php` for this
new 26.04 installation. Keep MariaDB administration on its local Unix socket:

```bash
sudo systemctl enable --now mariadb apache2
sudo mariadb -e 'SELECT VERSION();'
```

Keep MariaDB listening locally. Create its override:

```bash
sudoedit /etc/mysql/mariadb.conf.d/60-monarc.cnf
```

Use:

```ini
[mysqld]
bind-address = 127.0.0.1
```

```bash
sudo systemctl restart mariadb
```

## 4. Configure PHP and Apache

Create the PHP override:

```bash
sudoedit /etc/php/8.4/mods-available/monarc.ini
```

Use:

```ini
upload_max_filesize = 200M
post_max_size = 200M
max_execution_time = 520
max_input_time = 223
memory_limit = 512M
display_errors = Off
log_errors = On
expose_php = Off
session.cookie_httponly = 1
session.cookie_samesite = Lax
session.cookie_secure = 1
```

This guide enables HTTPS before the first login. Enable this configuration for
both web requests and CLI migrations:

```bash
sudo phpenmod -v 8.4 -s apache2 monarc
sudo phpenmod -v 8.4 -s cli monarc
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork php8.4 rewrite headers ssl
sudo apache2ctl configtest
sudo systemctl restart apache2
```

On this fresh server only PHP 8.4 should be enabled in Apache. Check
`apache2ctl -M` and disable any other `php*.load` module before enabling sites.

## 5. Install Composer for validation

Follow the [Composer installer verification procedure](https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md).
Run in your SSH user's temporary directory, not in an application directory:

```bash
composer_dir=$(mktemp -d)
cd "$composer_dir"
curl -fsSL https://getcomposer.org/installer -o composer-setup.php
curl -fsSL https://composer.github.io/installer.sig -o installer.sig
php8.4 -r '$expected = trim(file_get_contents("installer.sig")); if (!hash_equals($expected, hash_file("sha384", "composer-setup.php"))) { fwrite(STDERR, "Composer installer checksum mismatch\n"); exit(1); }'
# Continue only when checksum verification succeeds:
php8.4 composer-setup.php --2 --filename=composer
sudo install -m 0755 composer /usr/local/bin/composer
composer --version
```

## 6. Extract the manual pair

```bash
cd /tmp
sha256sum --check MONARC-SHA256SUMS
# Continue only when both checksums match:
for app in /var/lib/monarc/manual-bo /var/lib/monarc/manual-fo; do
    if sudo test -e "$app" || sudo test -L "$app"; then
        echo "Application destination already exists: $app" >&2
        exit 1
    fi
done
sudo install -d -m 0755 /var/lib/monarc
sudo install -d -m 0750 -o root -g www-data /var/lib/monarc/manual-bo /var/lib/monarc/manual-fo
sudo tar --no-same-owner -xzf monarc-bo-candidate.tar.gz -C /var/lib/monarc/manual-bo
sudo tar --no-same-owner -xzf monarc-fo-candidate.tar.gz -C /var/lib/monarc/manual-fo
sudo chown -R root:www-data /var/lib/monarc/manual-bo /var/lib/monarc/manual-fo
sudo chmod -R u=rwX,g=rX,o= /var/lib/monarc/manual-bo /var/lib/monarc/manual-fo
```

These are fresh directories; do not extract an installation archive over an
existing site's configuration or uploads. For each application:

```bash
for office in bo fo; do
    app="/var/lib/monarc/manual-$office"
    sudo mkdir -p "$app/data/cache" "$app/data/LazyServices/Proxy" \
        "$app/data/DoctrineORMModule/Proxy" "$app/data/import/files" \
        "$app/data/monarc/models" "$app/public/captcha"
    sudo chown -R www-data:www-data "$app/data" "$app/public/captcha"
    sudo chmod -R u=rwX,g=rX,o= "$app/data" "$app/public/captcha"
    sudo -u www-data bash -c 'cd "$1" && php8.4 tests/released-sources.php && php8.4 tests/locked-doctrine.php' -- "$app"
done
```

Keep the packaged `data/fonts` files. Do not make application source or `vendor`
writable by Apache. Code can be shared as immutable artifacts, but each deployed
application needs its own writable data, caches, proxies, CAPTCHA and uploads.

## 7. Create the manual pair's databases

Generate two different long passwords, for example using `openssl rand -hex 32`,
and save them in your password manager. In the following SQL replace both
`REPLACE_...` values before executing it through MariaDB:

```bash
sudo mariadb
```

```sql
CREATE DATABASE manual_common CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE DATABASE manual_master CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE DATABASE manual_cli CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE USER 'manual_bo'@'localhost' IDENTIFIED BY 'REPLACE_BO_PASSWORD';
GRANT ALL PRIVILEGES ON manual_common.* TO 'manual_bo'@'localhost';
GRANT ALL PRIVILEGES ON manual_master.* TO 'manual_bo'@'localhost';

CREATE USER 'manual_fo'@'localhost' IDENTIFIED BY 'REPLACE_FO_PASSWORD';
GRANT ALL PRIVILEGES ON manual_common.* TO 'manual_fo'@'localhost';
GRANT ALL PRIVILEGES ON manual_cli.* TO 'manual_fo'@'localhost';
QUIT;
```

Use `utf8mb4_general_ci` consistently for the new pair. The legacy FrontOffice
migration `20230901112005` converts metadata tables to this collation before
joining their translation keys to `translations`; a different database default
can cause error 1267 during that migration.

Application accounts receive privileges only on their own pair's schemas.
The migration scripts need DDL privileges. Neither application uses MariaDB root.

Bootstrap the shared common database **once, from BackOffice**, before migrating:

```bash
sudo bash -c 'mariadb manual_common < /var/lib/monarc/manual-bo/db-bootstrap/monarc_structure.sql'
sudo bash -c 'mariadb manual_common < /var/lib/monarc/manual-bo/db-bootstrap/monarc_data.sql'
```

These SQL files contain destructive initialization statements. Do not rerun them
on an initialized database. Do not import the FO common bootstrap into this
shared database afterwards. The BO master and FO client schemas are created by
their office migrations.

## 8. Configure each application

Copy each application's own template:

```bash
sudo cp /var/lib/monarc/manual-bo/config/autoload/local.php.dist /var/lib/monarc/manual-bo/config/autoload/local.php
sudo cp /var/lib/monarc/manual-fo/config/autoload/local.php.dist /var/lib/monarc/manual-fo/config/autoload/local.php
sudoedit /var/lib/monarc/manual-bo/config/autoload/local.php
sudoedit /var/lib/monarc/manual-fo/config/autoload/local.php
```

Preserve the rest of each template and make these substitutions:

| Setting | Manual BO | Manual FO |
|---|---|---|
| `$appdir` fallback | `/var/lib/monarc/manual-bo` | `/var/lib/monarc/manual-fo` |
| Both connections' `host` | `localhost` | `localhost` |
| Both connections' `port` | `3306` | `3306` |
| Both connections' `user` | `manual_bo` | `manual_fo` |
| Both connections' `password` | BO password | FO password |
| `orm_default.params.dbname` | `manual_common` | `manual_common` |
| `orm_cli.params.dbname` | `manual_master` | `manual_cli` |
| `publicHost` | `https://bo-manual.example.com` | `https://fo-manual.example.com` |

In BO's template, replace the relative `file_get_contents('./package.json')`
with a path based on `$appdir`, as FO's template already does:

```php
$appdir = getenv('APP_DIR') ?: '/var/lib/monarc/manual-bo';
$package_json = json_decode(file_get_contents($appdir . '/package.json'), true);
```

Set `publicHost` as a top-level configuration option: password-reset links
require a trusted absolute public URL. Also set each site's `instanceName` and `email.from`;
retain FO's absolute import path and `/usr/bin/soffice` PDF converter. FO's
template has the production CAPTCHA settings and bundled font location.

```bash
sudo chown root:www-data /var/lib/monarc/manual-{bo,fo}/config/autoload/local.php
sudo chmod 0640 /var/lib/monarc/manual-{bo,fo}/config/autoload/local.php
sudo php8.4 -l /var/lib/monarc/manual-bo/config/autoload/local.php
sudo php8.4 -l /var/lib/monarc/manual-fo/config/autoload/local.php
```

The CLI migration files read `config/autoload/local.php` from the application
directory. Set that file even when Apache is configured through environment
variables. Use the packaged `global.php`; do not replace it with an old dist file.

## 9. Migrate BackOffice first, then FrontOffice

Keep sites unavailable to users during initialization. Each command must succeed
before continuing:

```bash
sudo -u www-data bash -c 'cd /var/lib/monarc/manual-bo && APP_ENV=production APP_DIR=/var/lib/monarc/manual-bo bash scripts/upgrade-db.sh'
sudo -u www-data bash -c 'cd /var/lib/monarc/manual-bo && APP_ENV=production APP_DIR=/var/lib/monarc/manual-bo php8.4 vendor/robmorgan/phinx/bin/phinx seed:run -c module/Monarc/BackOffice/migrations/phinx.php'

sudo -u www-data bash -c 'cd /var/lib/monarc/manual-fo && APP_ENV=production APP_DIR=/var/lib/monarc/manual-fo bash scripts/upgrade-db.sh'
sudo -u www-data bash -c 'cd /var/lib/monarc/manual-fo && APP_ENV=production APP_DIR=/var/lib/monarc/manual-fo php8.4 vendor/robmorgan/phinx/bin/phinx seed:run -c module/Monarc/FrontOffice/migrations/phinx.php'
```

Run each initial seed only once against its fresh office database. The current
seeds create `admin@admin.localhost` with password `admin`; change both passwords
at first login. They are not a general-purpose, repeatable update operation.

Sharing the common database links reference definitions. The FO seed does not
register that instance as a client in BO's provisioning inventory. If testing BO
client lifecycle automation, also exercise BO client creation and its real
inventory/bootstrap workflow; do not treat a separately seeded FO as proof that
automatic provisioning has passed.

Document templates also have filesystem content: packaged defaults are present
in each artifact, while BO-uploaded templates may need synchronization to the
matching FO. Test this explicitly when validating deliveries. Synchronize files
only to the matching FO; database sharing does not copy template files.

Do **not** use `scripts/update-all.sh` on this artifact-based server. That helper
pulls source and reinstalls frontend dependencies. Deploy the approved prepared
artifact and use `scripts/upgrade-db.sh` for migrations.

## 10. Add two Apache virtual hosts

Create `/etc/apache2/sites-available/monarc-manual-bo.conf`:

```apache
<VirtualHost *:80>
    ServerName bo-manual.example.com
    DocumentRoot /var/lib/monarc/manual-bo/public
    SetEnv APP_ENV production
    SetEnv APPLICATION_ENV production
    SetEnv APP_DIR /var/lib/monarc/manual-bo

    <Directory /var/lib/monarc/manual-bo/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        DirectoryIndex index.php
        Require all granted
    </Directory>

    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
    ErrorLog ${APACHE_LOG_DIR}/monarc-manual-bo-error.log
    CustomLog ${APACHE_LOG_DIR}/monarc-manual-bo-access.log combined
</VirtualHost>
```

Create `monarc-manual-fo.conf` using the same configuration with the FO domain,
all `/manual-bo` paths changed to `/manual-fo`, and separate FO log names. Each
DocumentRoot must end in `/public`, never the application root.

```bash
sudo a2ensite monarc-manual-bo monarc-manual-fo
sudo apache2ctl configtest
sudo systemctl reload apache2
sudo apache2ctl -S
```

Keep all default and future site decisions explicit; do not disable unrelated
virtual hosts as part of either application's deployment.

## 11. Configure HTTPS and mail

With real DNS records and inbound ports 80/443 available, obtain a certificate
for each manual site:

```bash
sudo certbot --apache --redirect -d bo-manual.example.com
sudo certbot --apache --redirect -d fo-manual.example.com
sudo certbot renew --dry-run
```

For private DNS names use your internal CA or an appropriate DNS challenge.
Do not use example domains literally. See the [Certbot Apache instructions](https://certbot.eff.org/instructions).

Configure real SMTP before testing password reset. Two supported choices are:

- Configure `smtpOptions` in each `local.php` to use your authenticated SMTP relay.
- Install `postfix` and `libsasl2-modules`, configure Postfix as a loopback-only
  satellite relay, and point both applications to `127.0.0.1:25`.

For direct SMTP, merge this into each application's configuration using your
relay's real values:

```php
'smtpOptions' => [
    'name' => 'fo-manual.example.com',
    'host' => 'smtp.example.com',
    'port' => 587,
    'connection_class' => 'login',
    'connection_config' => [
        'username' => 'REPLACE_SMTP_USER',
        'password' => 'REPLACE_SMTP_PASSWORD',
        'ssl' => 'tls',
    ],
],
```

Use the appropriate sender/name for each application and a sender accepted by
your relay. After configuring the databases and local files, clear only the
applications' generated configuration caches and reload Apache:

```bash
for app in /var/lib/monarc/manual-bo /var/lib/monarc/manual-fo; do
    sudo find "$app/data/cache" -mindepth 1 -maxdepth 1 -type f -delete
done
sudo apache2ctl configtest
sudo systemctl reload apache2
curl --fail --silent --show-error --head https://bo-manual.example.com/
curl --fail --silent --show-error --head https://fo-manual.example.com/
```

Repeat the cache-clear/reload step after later `local.php` changes. Verify actual
receipt of a password-reset message and its HTTPS hostname for each office.
Installing PHP alone does not configure mail.

## 12. Optional statistics service

The statistics dashboard is a separate application. It is not required to start
FO or BO. Configure it after the core sites pass their checks:

| Setting | Value |
|---|---|
| Listener | `127.0.0.1:5005` |
| PostgreSQL database/user | `manual_stats` |
| Source/runtime path | `/var/lib/monarc/manual-stats` |

Install `postgresql`, `python3-venv` and `python3-poetry` if deploying from source.
Use a pinned stats-service release, its npm lock on the build machine and a
Poetry-managed Python 3.12 environment, rather than assuming the Ubuntu system
Python matches the existing lock. Build/deploy a pinned production WSGI server
such as Gunicorn with that environment; the Vagrant `flask run` service is a
development example.

Create each PostgreSQL database under its own non-superuser owner, configure its
`instance/production.py` with a unique secret and database credentials, initialize
it with `FLASK_APP=app.py STATS_CONFIG=production.py ... flask db_init`, and create
an FO client token with `flask client_create`. An example systemd service for the
manual instance, after its virtualenv and WSGI server are prepared, is:

```ini
[Unit]
Description=MONARC manual statistics
After=network.target postgresql.service

[Service]
User=monarc-stats
Group=monarc-stats
WorkingDirectory=/var/lib/monarc/manual-stats
Environment=STATS_CONFIG=production.py
ExecStart=/var/lib/monarc/manual-stats/.venv/bin/gunicorn --bind 127.0.0.1:5005 --workers 2 app:application
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Create the service account and writable log/runtime directories first. Set FO's
`statsApi.baseUrl` and `statsApi.apiKey` to its matching service and token. If the
dashboard is exposed to browsers, add a dedicated HTTPS reverse-proxy vhost;
keep the database and Gunicorn listeners private. See the
[stats-service installation documentation](https://www.monarc.lu/documentation/stats-service/installation.html)
for configuration fields and application commands. This optional service needs
its own dependency audit and end-to-end validation; core PHP validation does not
validate it.

## 13. Validate and record the manual pair

Record the source commit, both artifact SHA-256 values, Ubuntu/PHP/MariaDB
versions, migration output, Apache configuration and test results.

- Confirm both sites load over HTTPS and each login reaches the correct office.
- Change initial passwords and test reset email on both sites.
- In BO, create/update a definition and verify it is available to the matching FO.
- In FO, create an analysis; test a supported import/export and a PDF delivery.
- Verify CAPTCHA images, file uploads and background/CLI operations you enable.
- Check both Apache error logs for exceptions, permission errors and PHP diagnostics.
- Restart Apache and MariaDB and verify the sites again.

Back up **all three databases together**, plus both applications' `local.php`,
data, uploads and writable templates. Test restoration on a disposable instance.
Switching an application artifact back does not reverse database migrations.

Only SSH and HTTPS/HTTP as needed should be externally reachable. Adapt your
firewall to the actual SSH port before enabling it; MariaDB, PostgreSQL and
statistics listeners remain private.

## References

- [Ubuntu PHP package](https://packages.ubuntu.com/resolute/php): the default PHP line is 8.5.
- [Sury repository setup](https://packages.sury.org/php/README.txt).
- [Ubuntu Apache installation](https://ubuntu.com/server/docs/how-to/web-services/install-apache2/).
- [Composer installation verification](https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md).
- [Node release status](https://nodejs.org/en/about/previous-releases): the retained Node 16 build runtime is EOL and belongs in the isolated build environment.

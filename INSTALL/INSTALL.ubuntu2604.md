Installation on Ubuntu 26.04
============================

This guide installs one standalone FrontOffice at `/var/lib/monarc/fo`, using
its own `monarc_common` and `monarc_cli` databases. Replace `fo.example.com` with
your server's DNS name. Run the commands through an SSH user with sudo access.

For a linked FrontOffice/BackOffice deployment, use
[the FO/BO pair guide](INSTALL.ubuntu2604-fo-bo.md) instead of creating and
bootstrapping a separate common database here. The
[Ansible deployment guide](INSTALL.ubuntu2604-ansible.md) covers automation and
comparison of two pairs on one server.

# 1. Dependencies

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

# 2. Monarc files

Use an approved, assembled FrontOffice release archive containing `vendor`,
frontend dependencies, resource links, translations and fonts. For a release
candidate, prepare it on a separate build machine with
[`prepare-release.sh`](../scripts/prepare-release.sh), as described in
[released component assembly](../README.md#released-component-assembly).
Node.js 16 is used for that build, not for serving the assembled application.

Transfer the approved archive and its SHA-256 checksum file to `/tmp` on the
server. The examples call them `monarc-fo-candidate.tar.gz` and
`MONARC-FO-SHA256SUMS`; the checksum file must reference that archive name.

```bash
cd /tmp
sha256sum --check MONARC-FO-SHA256SUMS
# Refuse an existing directory or symlink; this is a fresh installation.
if sudo test -e /var/lib/monarc/fo || sudo test -L /var/lib/monarc/fo; then
    echo "Application destination already exists; use an upgrade procedure." >&2
    exit 1
fi
sudo install -d -m 0755 /var/lib/monarc
sudo install -d -m 0750 -o root -g www-data /var/lib/monarc/fo
sudo tar --no-same-owner -xzf monarc-fo-candidate.tar.gz -C /var/lib/monarc/fo
sudo chown -R root:www-data /var/lib/monarc/fo
sudo chmod -R u=rwX,g=rX,o= /var/lib/monarc/fo
sudo mkdir -p /var/lib/monarc/fo/data/cache \
    /var/lib/monarc/fo/data/LazyServices/Proxy \
    /var/lib/monarc/fo/data/DoctrineORMModule/Proxy \
    /var/lib/monarc/fo/data/import/files \
    /var/lib/monarc/fo/data/monarc/models \
    /var/lib/monarc/fo/public/captcha
sudo chown -R www-data:www-data /var/lib/monarc/fo/data /var/lib/monarc/fo/public/captcha
sudo chmod -R u=rwX,g=rX,o= /var/lib/monarc/fo/data /var/lib/monarc/fo/public/captcha
sudo -u www-data bash -c 'cd /var/lib/monarc/fo && php8.4 tests/released-sources.php && php8.4 tests/locked-doctrine.php'
```

Use a fresh destination. Preserve the packaged `data/fonts` directory and keep
application source and `vendor` read-only to Apache. Do not unpack a fresh
installation over an existing site's configuration or uploads.

# 3. Webserver

## 3.1 Configure PHP and enable Apache modules

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

## 3.2 Configure the virtual host

Create the site's configuration:

```bash
sudoedit /etc/apache2/sites-available/monarc-fo.conf
```

Use:

```apache
<VirtualHost *:80>
    ServerName fo.example.com
    DocumentRoot /var/lib/monarc/fo/public
    SetEnv APP_ENV production
    SetEnv APPLICATION_ENV production
    SetEnv APP_DIR /var/lib/monarc/fo

    <Directory /var/lib/monarc/fo/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        DirectoryIndex index.php
        Require all granted
    </Directory>

    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
    ErrorLog ${APACHE_LOG_DIR}/monarc-fo-error.log
    CustomLog ${APACHE_LOG_DIR}/monarc-fo-access.log combined
</VirtualHost>
```

```bash
sudo a2ensite monarc-fo
sudo apache2ctl configtest
sudo systemctl reload apache2
sudo apache2ctl -S
```

The DocumentRoot must end in `/public`. Leave unrelated Apache sites enabled.
The application becomes usable after the database steps below are complete.

## 3.3 HTTPS

With real DNS records and inbound ports 80/443 available, obtain a certificate
for this site:

```bash
sudo certbot --apache --redirect -d fo.example.com
sudo certbot renew --dry-run
```

For private DNS names use your internal CA or an appropriate DNS challenge.
Do not use example domains literally. See the [Certbot Apache instructions](https://certbot.eff.org/instructions).


# 4. Database

These steps are for a new standalone installation. Administer MariaDB locally
with `sudo mariadb`; do not use the database root account in MONARC.

## 4.1 Create a database user

Generate a long password, for example with `openssl rand -hex 32`, and save it
in your password manager. Replace `REPLACE_FO_PASSWORD` before running this SQL
in MariaDB:

```bash
sudo mariadb
```

```sql
CREATE USER 'monarc_fo'@'localhost' IDENTIFIED BY 'REPLACE_FO_PASSWORD';
GRANT ALL PRIVILEGES ON monarc_common.* TO 'monarc_fo'@'localhost';
GRANT ALL PRIVILEGES ON monarc_cli.* TO 'monarc_fo'@'localhost';
```

The schema-specific privileges include the DDL operations needed by migrations.

## 4.2 Create two databases

In the same MariaDB session:

```sql
CREATE DATABASE monarc_common CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE monarc_cli CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
QUIT;
```

`monarc_common` contains reference definitions and models. `monarc_cli` contains
the FrontOffice users, client information and analyses.

## 4.3 Initialize the common database

```bash
sudo bash -c 'mariadb monarc_common < /var/lib/monarc/fo/db-bootstrap/monarc_structure.sql'
sudo bash -c 'mariadb monarc_common < /var/lib/monarc/fo/db-bootstrap/monarc_data.sql'
```

Run these imports once, against the new empty common database. They contain
destructive initialization statements. Do not run them against existing data or
a common database already initialized by BackOffice.

## 4.4 Configure the database connection

```bash
sudo cp /var/lib/monarc/fo/config/autoload/local.php.dist /var/lib/monarc/fo/config/autoload/local.php
sudoedit /var/lib/monarc/fo/config/autoload/local.php
```

Keep the rest of the template, including language and CAPTCHA settings, and set:

| Setting | Value |
|---|---|
| `$appdir` fallback | `/var/lib/monarc/fo` |
| Both connections' `host` | `localhost` |
| Both connections' `port` | `3306` |
| Both connections' `user` | `monarc_fo` |
| Both connections' `password` | Your database password |
| `orm_default.params.dbname` | `monarc_common` |
| `orm_cli.params.dbname` | `monarc_cli` |
| `publicHost` | `https://fo.example.com` |

Set `instanceName` and `email.from` for your site. Keep the import path beneath
`$appdir . '/data/import/files'` and the PDF converter at `/usr/bin/soffice`.


Set the template's top-level `publicHost` option to your real HTTPS address;
do not leave its default empty value. It is required for password-reset links:

```php
'publicHost' => 'https://fo.example.com',
```

Configure real SMTP before testing password reset. Two supported choices are:

- Configure `smtpOptions` in `local.php` to use your authenticated SMTP relay.
- Install `postfix` and `libsasl2-modules`, configure Postfix as a loopback-only
  satellite relay, and point the application to `127.0.0.1:25`.

For direct SMTP, merge this into the application's configuration using your
relay's real values:

```php
'smtpOptions' => [
    'name' => 'fo.example.com',
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

Set `email.from` to a sender accepted by your relay. Keep real credentials only
in the protected local configuration. Test actual delivery after configuration
and database initialization are complete.

```bash
sudo chown root:www-data /var/lib/monarc/fo/config/autoload/local.php
sudo chmod 0640 /var/lib/monarc/fo/config/autoload/local.php
sudo php8.4 -l /var/lib/monarc/fo/config/autoload/local.php
```

Use the packaged `global.php`. The CLI migration configuration reads the local
file from the application directory, so keep it configured even when Apache
also supplies environment variables.

## 4.5 Apply migrations

```bash
sudo -u www-data bash -c 'cd /var/lib/monarc/fo && APP_ENV=production APP_DIR=/var/lib/monarc/fo bash scripts/upgrade-db.sh'
```

This applies Core migrations to the common database and FrontOffice migrations
to the client database. Stop and resolve any migration failure before proceeding.
For an assembled release, use this migration helper rather than `update-all.sh`,
which also pulls source and reinstalls frontend dependencies.

## 4.6 Create the initial user

Run once against the fresh client database:

```bash
sudo -u www-data bash -c 'cd /var/lib/monarc/fo && APP_ENV=production APP_DIR=/var/lib/monarc/fo php8.4 vendor/robmorgan/phinx/bin/phinx seed:run -c module/Monarc/FrontOffice/migrations/phinx.php'
```

The initial seed is not an update step.

Before the first login, clear only this application's generated configuration
cache and reload Apache:

```bash
sudo find /var/lib/monarc/fo/data/cache -mindepth 1 -maxdepth 1 -type f -delete
sudo apache2ctl configtest
sudo systemctl reload apache2
curl --fail --silent --show-error --head https://fo.example.com/
```

Repeat this cache-clear/reload step after later changes to `local.php`, including
SMTP or public URL changes. Do not delete uploads, templates or database data.
Open `https://fo.example.com`. The initial login is `admin@admin.localhost` with
password `admin`; change it immediately. Test that a password-reset email contains
the correct HTTPS hostname.

Test password reset, analysis creation, a supported import/export, CAPTCHA and
PDF delivery. Inspect the site's Apache error log. Back up both databases,
configuration, uploads and writable templates together and test a restore.

# 5. Statistics for Global Dashboard

Statistics is a separate, optional service. If needed, deploy a pinned
stats-service release with PostgreSQL, its own database credentials and a unique
secret. For a source deployment on Ubuntu 26.04, install `postgresql`,
`python3-venv` and `python3-poetry`, use a Poetry-managed Python 3.12 environment
for the existing dependency lock, and run a production WSGI server such as
Gunicorn. Keep its listener local, for example `127.0.0.1:5005`.

Create an FO client token in that service, then set `statsApi.baseUrl` and
`statsApi.apiKey` in FrontOffice's `local.php`. Test the statistics integration
separately from the core PHP installation.

See the [stats-service installation documentation](https://www.monarc.lu/documentation/stats-service/installation.html)
and [architecture](https://www.monarc.lu/documentation/stats-service/master/architecture.html).

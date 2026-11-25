# MONARC App FO - Container Build Guide

This repository contains the Containerfiles/Dockerfiles and build instructions for packaging the MONARC Front-Office application components using `buildah`.

---

## Prerequisites

- **Build Tool:** `buildah` (or `podman` / `docker` with equivalent build context support)
- **Configuration File:** `argfile.conf` in the working directory (required for `monarcappfo` build)

---

## Configuration Setup

Before building the primary application image (`monarcappfo`), create or verify the `argfile.conf` file in your build root. This file injects runtime mail server configurations into the `/etc/msmtprc` file inside the image.

### `argfile.conf` Example

```ini
SMTP_HOST=mail.yourdomain.lu
SMTP_FROM=no-reply@yourdomain.lu
SMTP_DOMAIN=yourdomain.lu
```

### Mail Relay Configuration (`/etc/msmtprc`)

The build process replaces placeholders in `/etc/msmtprc` using the values supplied in `argfile.conf`:

```ini
# Set defaults
defaults
auth            off
tls             off
logfile         /dev/stdout

# Define relayhost account
account         default
host            SMTP_HOST
port            25
from            SMTP_FROM
auto_from       on
maildomain      SMTP_DOMAIN
```

---

## Build Instructions

Execute the following commands from the root of this context directory.

### 1. Main Application (`monarcappfo`)

Builds the core application image, utilizing build arguments from `argfile.conf` and referencing the parent MONARC source directory:

```bash
buildah bud \
  --build-arg-file argfile.conf \
  --build-context monarcdir=../.. \
  -t monarcappfo:v2.14.2
```

### 2. Database (`monarcappfo-mariadb`)

Builds the customized MariaDB 10.11 database image:

```bash
buildah bud \
  --build-context monarcdir=../.. \
  -t monarcappfo-mariadb:10.11
```

### 3. Statistics Service (`monarcappfo-stats`)

Builds the statistics companion microservice image:

```bash
buildah bud \
  -t monarcappfo-stats:v2.14.2
```

---

## Image Summary

| Image Target | Tag | Description | Dependencies |
| :--- | :--- | :--- | :--- |
| `monarcappfo` | `v2.14.2` | Core MONARC Application | Requires `argfile.conf` & `monarcdir` context |
| `monarcappfo-mariadb` | `10.11` | MariaDB Database | Requires `monarcdir` context |
| `monarcappfo-stats` | `v2.14.2` | Statistics Service | Standalone build |

---

## Verification

After building, verify that all local images were tagged successfully:

```bash
buildah images | grep monarcappfo
```

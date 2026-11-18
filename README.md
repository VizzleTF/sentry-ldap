# Sentry with LDAP Authentication

Docker image for Sentry with LDAP authentication support. Automatically built daily when new Sentry versions are released.

## Quick Start

```bash
docker pull ghcr.io/vizzletf/sentry-ldap:latest
```

## Usage

This image extends the official Sentry image with `sentry-auth-ldap`, `django-auth-ldap` and `python-ldap` pre-installed. Images exist for Sentry 25.9.0 and later.

### With self-hosted Sentry

The self-hosted `docker-compose.yml` builds a local image `FROM ${SENTRY_IMAGE}`, so point `SENTRY_IMAGE` at this image. Use the tag that matches your self-hosted release.

1. Clone [getsentry/self-hosted](https://github.com/getsentry/self-hosted) and check out your release, for example `26.11.0`.
2. Create `.env.custom` from `.env` and set the image. The later `SENTRY_IMAGE` line wins:

   ```bash
   cp .env .env.custom
   echo 'SENTRY_IMAGE=ghcr.io/vizzletf/sentry-ldap:26.11.0' >> .env.custom
   ```

3. Add the LDAP settings to `sentry/sentry.conf.py` (see `sentry.conf.example.py`).
4. Run `./install.sh`, then `docker compose up -d`.

Do not replace `image:` in `docker-compose.yml`: the compose file builds and tags the local image from `SENTRY_IMAGE`, so a replaced `image:` ends up without LDAP support.

### Configuration

Copy `sentry.conf.example.py` to your Sentry config directory and modify the settings:

- `AUTH_LDAP_SERVER_URI` - LDAP server URL
- `AUTH_LDAP_BIND_DN` / `AUTH_LDAP_BIND_PASSWORD` - Bind credentials
- `AUTH_LDAP_USER_SEARCH` - User search configuration
- `AUTH_LDAP_SENTRY_DEFAULT_ORGANIZATION` - Default org for new users

## Available Tags

- `latest` - Latest Sentry version with LDAP support
- `<version>` - Specific Sentry version (e.g., `26.11.0`)

## Building Locally

`SENTRY_VERSION` is required. The build needs BuildKit, the default builder since Docker 23.

```bash
docker build --build-arg SENTRY_VERSION=26.11.0 -t sentry-ldap:26.11.0 .
```

The LDAP packages are pinned with hashes in `requirements.txt`. The build fails if the LDAP backend does not load against that Sentry version.

## GitHub Actions

The workflow automatically:
- Checks for new Sentry releases daily at 00:00 UTC
- Builds and pushes new images when updates are found
- Supports manual trigger with force build option
- Opens or updates the issue "Image build is failing" when a run fails
- Attests build provenance; verify an image with `gh attestation verify oci://ghcr.io/vizzletf/sentry-ldap:26.11.0 -R VizzleTF/sentry-ldap`

## License

MIT

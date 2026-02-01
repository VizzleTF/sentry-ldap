# Sentry with LDAP Authentication

Docker image for Sentry with LDAP authentication support. Automatically built daily when new Sentry versions are released.

## Quick Start

```bash
docker pull ghcr.io/vizzletf/sentry-ldap:latest
```

## Usage

This image extends the official Sentry image with `sentry-auth-ldap` package pre-installed.

### With Docker Compose (Self-Hosted Sentry)

1. Clone the [getsentry/self-hosted](https://github.com/getsentry/self-hosted) repository
2. Replace the Sentry image in `docker-compose.yml`:

```yaml
x-sentry-defaults: &sentry_defaults
  image: ghcr.io/vizzletf/sentry-ldap:latest
```

3. Add LDAP configuration to `sentry/sentry.conf.py` (see `sentry.conf.example.py`)
4. Run `./install.sh` and `docker compose up -d`

### Configuration

Copy `sentry.conf.example.py` to your Sentry config directory and modify the settings:

- `AUTH_LDAP_SERVER_URI` - LDAP server URL
- `AUTH_LDAP_BIND_DN` / `AUTH_LDAP_BIND_PASSWORD` - Bind credentials
- `AUTH_LDAP_USER_SEARCH` - User search configuration
- `AUTH_LDAP_SENTRY_DEFAULT_ORGANIZATION` - Default org for new users

## Available Tags

- `latest` - Latest Sentry version with LDAP support
- `<version>` - Specific Sentry version (e.g., `24.1.0`)

## Building Locally

```bash
docker build --build-arg SENTRY_VERSION=24.1.0 -t sentry-ldap:24.1.0 .
```

## GitHub Actions

The workflow automatically:
- Checks for new Sentry releases daily at 00:00 UTC
- Builds and pushes new images when updates are found
- Supports manual trigger with force build option

## License

MIT

# Sentry with LDAP authentication support
# Based on official Sentry image from GitHub Container Registry
ARG SENTRY_VERSION=latest
FROM ghcr.io/getsentry/sentry:${SENTRY_VERSION}

LABEL maintainer="vizzlef@gmail.com"
LABEL description="Sentry with LDAP authentication support"
LABEL org.opencontainers.image.source="https://github.com/VizzleTF/sentry-ldap"

# Install LDAP dependencies and sentry-auth-ldap
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        libldap2-dev \
        libsasl2-dev && \
    /.venv/bin/pip install --no-cache-dir python-ldap django-auth-ldap sentry-auth-ldap && \
    apt-get purge -y --auto-remove build-essential gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure LDAPS support (LDAP over TLS)
RUN mkdir -p /etc/ldap && \
    echo "TLS_CACERT /etc/ssl/certs/ca-certificates.crt" > /etc/ldap/ldap.conf

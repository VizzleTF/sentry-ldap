# Sentry with LDAP authentication support
# Based on official Sentry image from GitHub Container Registry
ARG SENTRY_VERSION=latest

# python-ldap ships only an sdist: compile it here so the final image carries no compiler or headers
FROM ghcr.io/getsentry/sentry:${SENTRY_VERSION} AS builder
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libldap-dev libsasl2-dev && \
    /.venv/bin/pip wheel --no-cache-dir --no-deps --wheel-dir /wheels python-ldap==3.4.8

FROM ghcr.io/getsentry/sentry:${SENTRY_VERSION}

LABEL maintainer="vizzlef@gmail.com"
LABEL description="Sentry with LDAP authentication support"
LABEL org.opencontainers.image.source="https://github.com/VizzleTF/sentry-ldap"

USER root
# Since 26.11.0 sentry is installed as version 0.0.0, so sentry-auth-ldap's "sentry>=23.6.0"
# can't resolve: install its pinned dependency first, then the plugin with --no-deps.
RUN --mount=type=bind,from=builder,source=/wheels,target=/wheels \
    apt-get update && \
    apt-get install -y --no-install-recommends libldap2 libsasl2-2 && \
    rm -rf /var/lib/apt/lists/* && \
    /.venv/bin/pip install --no-cache-dir /wheels/*.whl django-auth-ldap==4.1.0 && \
    /.venv/bin/pip install --no-cache-dir --no-deps sentry-auth-ldap==24.8.1.post1 && \
    mkdir -p /etc/ldap && \
    echo "TLS_CACERT /etc/ssl/certs/ca-certificates.crt" > /etc/ldap/ldap.conf && \
    /.venv/bin/python -c "import ldap, django_auth_ldap, sentry_auth_ldap"
USER sentry

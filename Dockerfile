# syntax=docker/dockerfile:1
# Sentry with LDAP authentication support, based on the official Sentry image
ARG SENTRY_VERSION

# Download hash-checked packages and compile python-ldap (sdist only),
# so the final image carries no compiler or headers
FROM ghcr.io/getsentry/sentry:${SENTRY_VERSION} AS builder
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libldap-dev libsasl2-dev
COPY requirements.txt /tmp/requirements.txt
RUN /.venv/bin/pip wheel --no-cache-dir --no-deps --require-hashes \
    --wheel-dir /wheels -r /tmp/requirements.txt

FROM ghcr.io/getsentry/sentry:${SENTRY_VERSION}

LABEL maintainer="vizzlef@gmail.com"
LABEL description="Sentry with LDAP authentication support"
LABEL org.opencontainers.image.source="https://github.com/VizzleTF/sentry-ldap"

USER root
# --no-deps: since 26.11.0 sentry is installed as version 0.0.0, which fails sentry-auth-ldap's
# "sentry>=23.6.0"; Django comes from the base image. The last command loads the backend
# against the real Sentry models, so an incompatible Sentry release fails the build.
RUN --mount=type=bind,from=builder,source=/wheels,target=/wheels \
    apt-get update && \
    apt-get install -y --no-install-recommends libldap2 libsasl2-2 && \
    rm -rf /var/lib/apt/lists/* && \
    /.venv/bin/pip install --no-cache-dir --no-index --no-deps /wheels/*.whl && \
    mkdir -p /etc/ldap && \
    echo "TLS_CACERT /etc/ssl/certs/ca-certificates.crt" > /etc/ldap/ldap.conf && \
    PYTHONDONTWRITEBYTECODE=1 SENTRY_REDIS_HOST=build-check SENTRY_POSTGRES_HOST=build-check \
    SENTRY_SECRET_KEY=build-check-only-not-a-real-secret-0123456789abcdef \
    /.venv/bin/python -c "from sentry.runner import configure; configure(skip_service_validation=True); \
import ldap; from sentry_auth_ldap.backend import SentryLdapBackend; SentryLdapBackend()"
USER sentry

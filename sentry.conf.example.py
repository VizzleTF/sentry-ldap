# Example Sentry LDAP Configuration
# Copy this to your Sentry config directory and modify as needed
#
# For self-hosted Sentry, add this content to:
# sentry/sentry.conf.py

import ldap
from django_auth_ldap.config import LDAPSearch, GroupOfUniqueNamesType

# =============================================================================
# LDAP Server Connection
# =============================================================================

# LDAP server URL (use ldaps:// for SSL/TLS)
AUTH_LDAP_SERVER_URI = 'ldap://your.ldap.server.com'

# Bind credentials (leave empty for anonymous bind)
AUTH_LDAP_BIND_DN = 'cn=admin,dc=example,dc=com'
AUTH_LDAP_BIND_PASSWORD = 'your-bind-password'

# =============================================================================
# User Search Configuration
# =============================================================================

# Search base and filter for finding users
AUTH_LDAP_USER_SEARCH = LDAPSearch(
    'ou=users,dc=example,dc=com',  # Base DN for user search
    ldap.SCOPE_SUBTREE,             # Search entire subtree
    '(uid=%(user)s)',               # Filter (use 'mail=%(user)s' for email login)
)

# Map LDAP attributes to Sentry user fields
AUTH_LDAP_USER_ATTR_MAP = {
    'username': 'uid',
    'name': 'cn',
    'email': 'mail',
}

# =============================================================================
# Group Configuration (Optional)
# =============================================================================

AUTH_LDAP_GROUP_SEARCH = LDAPSearch(
    'ou=groups,dc=example,dc=com',
    ldap.SCOPE_SUBTREE,
    '(objectClass=groupOfUniqueNames)'
)

AUTH_LDAP_GROUP_TYPE = GroupOfUniqueNamesType()

# Require membership in a specific group to login (optional)
# AUTH_LDAP_REQUIRE_GROUP = 'cn=sentry-users,ou=groups,dc=example,dc=com'

# Deny access to members of a specific group (optional)
# AUTH_LDAP_DENY_GROUP = 'cn=disabled-users,ou=groups,dc=example,dc=com'

# =============================================================================
# Sentry-specific LDAP Settings
# =============================================================================

# Default organization for new LDAP users (use organization slug)
AUTH_LDAP_SENTRY_DEFAULT_ORGANIZATION = 'my-organization'

# Default role for new users: 'owner', 'admin', 'manager', 'member'
AUTH_LDAP_SENTRY_ORGANIZATION_ROLE_TYPE = 'member'

# Allow global access to the organization
AUTH_LDAP_SENTRY_ORGANIZATION_GLOBAL_ACCESS = True

# Subscribe users to alerts by default
AUTH_LDAP_SENTRY_SUBSCRIBE_BY_DEFAULT = False

# Map LDAP groups to Sentry organization roles (optional)
# AUTH_LDAP_SENTRY_GROUP_ROLE_MAPPING = {
#     'owner': ['cn=sentry-admins,ou=groups,dc=example,dc=com'],
#     'admin': ['cn=sentry-managers,ou=groups,dc=example,dc=com'],
#     'member': ['cn=sentry-users,ou=groups,dc=example,dc=com'],
# }

# Map LDAP groups to Sentry teams (optional)
# AUTH_LDAP_SENTRY_GROUP_TEAM_MAPPING = {
#     'frontend': ['cn=frontend-devs,ou=groups,dc=example,dc=com'],
#     'backend': ['cn=backend-devs,ou=groups,dc=example,dc=com'],
# }

# =============================================================================
# Performance Settings
# =============================================================================

# Cache LDAP lookups (in seconds)
AUTH_LDAP_CACHE_TIMEOUT = 3600

# Set to True to enable group permission lookups
AUTH_LDAP_FIND_GROUP_PERMS = False

# =============================================================================
# Managed Fields
# =============================================================================

# Fields that users cannot edit in Sentry UI (managed by LDAP)
SENTRY_MANAGED_USER_FIELDS = ('email', 'first_name', 'last_name', 'password')

# =============================================================================
# Register LDAP Backend
# =============================================================================

AUTHENTICATION_BACKENDS = AUTHENTICATION_BACKENDS + (
    'sentry_auth_ldap.backend.SentryLdapBackend',
)

# =============================================================================
# Debug Logging (enable temporarily for troubleshooting)
# =============================================================================

# import logging
# logger = logging.getLogger('django_auth_ldap')
# logger.setLevel(logging.DEBUG)
# LOGGING['disable_existing_loggers'] = False

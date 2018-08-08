
from django.contrib.auth.middleware import RemoteUserMiddleware


class ReverseProxyAuthMiddleware(RemoteUserMiddleware):
    """
    """
    header = 'HTTP_X_SSL_CLIENT_S_DN'

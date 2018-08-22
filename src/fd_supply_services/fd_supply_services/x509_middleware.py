
import re

from django.contrib.auth.middleware import RemoteUserMiddleware
from django.contrib.auth.backends import RemoteUserBackend


class ReverseProxyAuthMiddleware(RemoteUserMiddleware):
    """
    """
    header = 'HTTP_X_SSL_CLIENT_S_DN'


class ReverseProxyRemoteUserBackend(RemoteUserBackend):
    """
    """

    def clean_username(self, username):
        """
        Reformats the subject for the passed in x509 cert and trims it down
        into a usable username. User certificate subjects follow this format:

          > CN=Brandon Test Admin Account,OU=App User Cert,O=simpkins.cloud
               --------------------------

        We want to get the CN field, strip the rest, and replace special chars
        that django complains about.

        Per the Django Admin UI:

          > "Enter a valid username. This value may contain only letters,
             numbers, and @/./+/-/_ characters."
        """

        # split the subject entries
        username = username.split(',')[0]

        # trim the prefix
        prefix = "CN="
        if username.startswith(prefix):
            username = username[len(prefix):]

        # remove everything that isn't alphanumeric
        username = re.sub('[^a-zA-Z0-9]', '', username)

        return username

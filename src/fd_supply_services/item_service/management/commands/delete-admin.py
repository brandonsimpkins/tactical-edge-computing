"""
Management utility to delete admin users.
"""

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = 'Deletes an admin user.'
    requires_migrations_checks = True

    def add_arguments(self, parser):
        parser.add_argument(
            'user_cert_dn',
            help="Should be the User Certificate DN (Distinguished Name)")

    def handle(self, *args, **options):

        try:

            # create a staff user (specifically without superuser rights!)
            user = User.objects.get(username=options['user_cert_dn'])
            user.delete()
            print("\nDeleted the '{0}' user.".format(
                options['user_cert_dn']))

        except User.DoesNotExist:

            # ignore errors if the user doesn't exist
            print("\nThe '{0}' user does not exist.".format(
                options['user_cert_dn']))

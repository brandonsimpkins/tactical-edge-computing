"""
Management utility to create admin users.
"""

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    help = 'Creates an admin user.'
    requires_migrations_checks = True

    def add_arguments(self, parser):
        parser.add_argument('user_cert_dn',
            help="Should be the User Certificate DN (Distinguished Name)")

    def handle(self, *args, **options):

        try:

            # try to update the user if he's in the database first
            user = User.objects.get(username = options['user_cert_dn'])
            user.is_staff=True
            user.is_superuser=True
            user.save()
            print("\nAdded is_staff access right to existing account:\n")

        except User.DoesNotExist:

            # create a new admin account for the specified cert dn
            user=User.objects.create_user(options['user_cert_dn'])
            user.is_staff=True
            user.is_superuser=True
            user.save()
            print("\nCreated new admin account:\n")

        finally:

            # query the user that was just created
            created_user = User.objects.get(username = options['user_cert_dn'])

            print("{0} {{".format(created_user.username))
            print("  name =         {0} {1}".format(created_user.first_name, created_user.last_name))
            print("  is_staff =     {0}".format(created_user.is_staff))
            print("  is_superuser = {0}".format(created_user.is_superuser))
            print("  is_active =    {0}".format(created_user.is_active))
            print("}\n")



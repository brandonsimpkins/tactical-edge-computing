"""
Management utility to list superusers.
"""

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    help = 'Lists superusers.'
    requires_migrations_checks = True

    def handle(self, *args, **options):

        print("\n\nAdmin users (have staff permissions):")
        print("-----------------------------------------------------\n")
        admin_users = User.objects.all().filter(is_staff = 't')
        for user in admin_users:
            print("{0} {{".format(user.username))
            print("  name =         {0} {1}".format(user.first_name, user.last_name))
            print("  is_staff =     {0}".format(user.is_staff))
            print("  is_superuser = {0}".format(user.is_superuser))
            print("  is_active =    {0}".format(user.is_active))
            print("}\n")

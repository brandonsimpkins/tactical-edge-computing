"""
Management utility to list superusers.
"""

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    help = 'Lists superusers.'
    requires_migrations_checks = True

    def handle(self, *args, **options):

        print("\n\nRegular (or Super) Application Users:")
        print("-----------------------------------------------------\n")
        admin_users = User.objects.all().filter(is_staff = 'f')
        for user in admin_users:
            print(user.username)
        print("")

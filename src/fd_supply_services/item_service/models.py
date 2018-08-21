# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models


class UnitIdentificationCode(models.Model):
    """
    Represents a UIC which inventory and locations are tied to.
    """
    uic = models.CharField(max_length=6, primary_key=True)
    description = models.CharField(max_length=255)
    address = models.CharField(max_length=255)

    class Meta:
        ordering = ('uic',)

    def __str__(self):
        return "UIC - {0}".format(self.uic)


class UnitOfIssue(models.Model):
    code = models.CharField(max_length=2, primary_key=True)
    description = models.CharField(max_length=16)

    class Meta:
        ordering = ('code',)

    def __str__(self):
        return "{0} - {1}".format(self.code, self.description)


class Item(models.Model):
    nsn = models.CharField("national stock number",
                           max_length=13, primary_key=True)
    category = models.CharField(max_length=100, blank=True, default='')
    common_name = models.CharField(max_length=100)
    description = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=6, decimal_places=2)
    ui = models.ForeignKey(UnitOfIssue)
    aac = models.CharField("acquisition advice code", max_length=1)
    # created = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ('nsn',)

    def __str__(self):
        return "Item NSN - {1}".format(self.nsn)

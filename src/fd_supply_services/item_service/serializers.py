from rest_framework import serializers
from item_service.models import Item, UnitOfIssue

class UnitOfIssueSerializer(serializers.ModelSerializer):
    """
    """
    class Meta:
        model = UnitOfIssue
        fields = ('code', 'description')

class ItemSerializer(serializers.ModelSerializer):
    """
    """

    class Meta:
        model = Item
        fields = '__all__'
        # depth = 1



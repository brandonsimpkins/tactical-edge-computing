from django.contrib.auth.models import User
from rest_framework import serializers

from item_service.models import Inventory
from item_service.models import Item
from item_service.models import UnitIdentificationCode
from item_service.models import UnitOfIssue


class UserSerializer(serializers.ModelSerializer):
    """
    """

    class Meta:
        model = User
        fields = '__all__'


class UnitIdentificationCodeSerializer(serializers.ModelSerializer):
    """
    """

    url = serializers.HyperlinkedIdentityField(
            view_name='uic-detail',
            format='html',
            lookup_field='uic')

    class Meta:
        model = UnitIdentificationCode
        fields = '__all__'


class UnitOfIssueSerializer(serializers.ModelSerializer):
    """
    """
    url = serializers.HyperlinkedIdentityField(
            read_only=True,
            view_name='unitofissue-detail',
            format='html',
            lookup_field='code')

    class Meta:
        model = UnitOfIssue
        fields = '__all__'


class ItemSerializer(serializers.ModelSerializer):
    """
    """

    url = serializers.HyperlinkedIdentityField(
            view_name='item-detail',
            format='html',
            lookup_field='nsn')

    class Meta:
        model = Item
        fields = '__all__'


class InventorySerializer(serializers.ModelSerializer):
    """
    """

    url = serializers.HyperlinkedIdentityField(
            view_name='inventory-detail',
            format='html',
            lookup_field='id')

    # def create(self, validated_data):
    #     """
    #     Override the id field on model creation.
    #     """
    #     print("\n\n\n Creating Inventory\n---------------------")
    #     import pprint
    #     pp = pprint.PrettyPrinter(indent=4)
    #     pp.pprint(validated_data)
    #
    #     validated_data['id'] = '{0}{1}'.format(
    #         validated_data['uic'].uic, validated_data['nsn'].nsn)
    #     return Inventory.objects.create(**validated_data)

    def validate(self, data):
        """
        Verify that the ID is a composite of the UIC and NSN
        """
        print("\n\n\n\n Inventory Cross Field Validation \n")

        composite_id = '{0}{1}'.format(data['uic'].uic, data['nsn'].nsn)
        print("data['id']: {0}".format(data['id']))
        print("composite id: {0}".format(composite_id))

        if data['id'] != composite_id:
            raise serializers.ValidationError(
                "inventory id does not match UIC and NSN. "
                "Should be {0}.".format(composite_id))
        return data

    class Meta:
        model = Inventory
        fields = '__all__'

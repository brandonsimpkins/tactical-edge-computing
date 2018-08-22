from django.contrib.auth.models import User
from rest_framework import generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.reverse import reverse

from item_service.models import Inventory
from item_service.models import Item
from item_service.models import UnitIdentificationCode
from item_service.models import UnitOfIssue

from item_service.serializers import InventorySerializer
from item_service.serializers import ItemSerializer
from item_service.serializers import UnitIdentificationCodeSerializer
from item_service.serializers import UnitOfIssueSerializer
from item_service.serializers import UserSerializer


@api_view(['GET'])
@permission_classes((permissions.IsAuthenticated,))
def api_root(request, format=None):
    return Response({
        'items': reverse('item-list', request=request, format=format),
        'units of issue': reverse('unitofissue-list', request=request, format=format),
        'users': reverse('user-list', request=request, format=format),
        'uics': reverse('uic-list', request=request, format=format),
        'inventory': reverse('inventory-list', request=request, format=format),
    })


class UserList(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAdminUser,)


class UserDetail(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAdminUser,)


class UnitIdentificationCodeList(generics.ListCreateAPIView):
    queryset = UnitIdentificationCode.objects.all()
    serializer_class = UnitIdentificationCodeSerializer
    permission_classes = (permissions.DjangoModelPermissions,)


class UnitIdentificationCodeDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = UnitIdentificationCode.objects.all()
    serializer_class = UnitIdentificationCodeSerializer
    permission_classes = (permissions.DjangoModelPermissions,)
    lookup_field = 'uic'


class UnitOfIssueList(generics.ListCreateAPIView):
    queryset = UnitOfIssue.objects.all()
    serializer_class = UnitOfIssueSerializer
    permission_classes = (permissions.DjangoModelPermissions,)


class UnitOfIssueDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = UnitOfIssue.objects.all()
    serializer_class = UnitOfIssueSerializer
    permission_classes = (permissions.DjangoModelPermissions,)
    lookup_field = 'code'


class ItemList(generics.ListCreateAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    permission_classes = (permissions.DjangoModelPermissions,)


class ItemDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    permission_classes = (permissions.DjangoModelPermissions,)
    lookup_field = 'nsn'


class InventoryList(generics.ListCreateAPIView):
    queryset = Inventory.objects.all()
    serializer_class = InventorySerializer
    permission_classes = (permissions.DjangoModelPermissions,)


class InventoryDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Inventory.objects.all()
    serializer_class = InventorySerializer
    permission_classes = (permissions.DjangoModelPermissions,)
    lookup_field = 'id'

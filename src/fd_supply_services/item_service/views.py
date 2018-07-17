from django.contrib.auth.models import User
from rest_framework import generics, permissions
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.reverse import reverse
from item_service.models import Item, UnitOfIssue
from item_service.serializers import UserSerializer, ItemSerializer, UnitOfIssueSerializer


@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'items': reverse('item-list', request=request, format=format),
        'units of issue': reverse('unitofissue-list', request=request, format=format)
    })


class UserList(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class UserDetail(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class UnitOfIssueList(generics.ListCreateAPIView):
    queryset = UnitOfIssue.objects.all()
    serializer_class = UnitOfIssueSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class UnitOfIssueDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = UnitOfIssue.objects.all()
    serializer_class = UnitOfIssueSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    lookup_field = 'code'


class ItemList(generics.ListCreateAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class ItemDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    lookup_field = 'nsn'

# -*- coding: utf-8 -*-
from item_service.models import Item, UnitOfIssue
from item_service.serializers import ItemSerializer, UnitOfIssueSerializer
from rest_framework import generics
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.reverse import reverse



@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'items': reverse('item-list', request=request, format=format),
        'units of issue': reverse('unitofissue-list', request=request, format=format)
    })


class UnitOfIssueList(generics.ListCreateAPIView):
    queryset = UnitOfIssue.objects.all()
    serializer_class = UnitOfIssueSerializer

class UnitOfIssueDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = UnitOfIssue.objects.all()
    serializer_class = UnitOfIssueSerializer
    lookup_field = 'code'

class ItemList(generics.ListCreateAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer

class ItemDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    lookup_field = 'nsn'

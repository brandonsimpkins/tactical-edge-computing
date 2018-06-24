# -*- coding: utf-8 -*-
from item_service.models import Item, UnitOfIssue
from item_service.serializers import ItemSerializer, UnitOfIssueSerializer
from rest_framework import generics


class UnitOfIssueList(generics.ListCreateAPIView):
    queryset = UnitOfIssue.objects.all()
    serializer_class = UnitOfIssueSerializer

class UnitOfIssueDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = UnitOfIssue.objects.all()
    serializer_class = UnitOfIssueSerializer

class ItemList(generics.ListCreateAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer

class ItemDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer

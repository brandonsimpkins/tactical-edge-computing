from django.conf.urls import url
from item_service import views

urlpatterns = [
    url(r'^$', views.api_root),
    url(r'^item/$',
        views.ItemList.as_view(),
        name="item-list"),
    url(r'^item/(?P<nsn>[0-9A-Za-z]+)/$',
        views.ItemDetail.as_view(),
        name="item-detail"),
    url(r'^unit-of-issue/$',
        views.UnitOfIssueList.as_view(),
        name="unitofissue-list"),
    url(r'^unit-of-issue/(?P<code>[A-Z]+)/$',
        views.UnitOfIssueDetail.as_view(),
        name="unitofissue-detail"),

]

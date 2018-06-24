from django.conf.urls import url
from item_service import views

urlpatterns = [
    url(r'^items/$', views.ItemList.as_view()),
    url(r'^items/(?P<pk>[0-9]+)/$', views.ItemDetail.as_view()),
    url(r'^unit-of-issue/$', views.UnitOfIssueList.as_view()),
    url(r'^unit-of-issue/(?P<pk>[0-9]+)/$', views.UnitOfIssueDetail.as_view()),

]

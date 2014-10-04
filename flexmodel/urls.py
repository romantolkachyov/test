# -*- coding: utf-8 -*-
from django.conf.urls import patterns, url
from api import urlpatterns as api_urlpatterns

urlpatterns = patterns('flexmodel.views',
    url(r'^$', 'home', name='home'),  # noqa
    *api_urlpatterns
)

# -*- coding: utf-8 -*-
from django.conf.urls import patterns, url

urlpatterns = patterns('flexmodel.views',
    url(r'^$', 'home', name='home'),  # noqa
)

from django.conf.urls import patterns, include, url
from django.contrib import admin

urlpatterns = patterns('',
    url(r'^', include('flexmodel.urls')),  # noqa

    url(r'^admin/', include(admin.site.urls)),
)

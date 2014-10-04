# -*- coding: utf-8 -*-
from django.conf.urls import url

from rest_framework.generics import ListCreateAPIView, RetrieveUpdateAPIView

import models

# class TestView(generics.ListCreateAPIView):
#     model = MyModel
#     serializer_class = UserSerializer
#     paginate_by = 100

urlpatterns = []

for model_name in models.flex_model_list:
    model = getattr(models, model_name)
    attrs = dict(model=model, paginate_by=50)
    # TODO: restframework routing, viewset
    list_api = type("%sList" % model_name, (ListCreateAPIView,), attrs)
    list_api_url = url(r"^api/%s$" % model_name, list_api.as_view())
    urlpatterns.append(list_api_url)

    attrs = dict(model=model)
    detail_api = type("%sDetail" % model_name, (RetrieveUpdateAPIView,), attrs)
    detail_api_url = url(r"^api/%s/(?P<pk>\d+)$" % model_name, detail_api.as_view())
    urlpatterns.append(detail_api_url)

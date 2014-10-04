# -*- coding: utf-8 -*-
from django.conf.urls import url

from rest_framework.generics import ListCreateAPIView

import models

# class TestView(generics.ListCreateAPIView):
#     model = MyModel
#     serializer_class = UserSerializer
#     paginate_by = 100

urlpatterns = []

for model_name in models.flex_model_list:
    model = getattr(models, model_name)
    attrs = dict(model=model, paginate_by=50)
    new_api = type(model_name, (ListCreateAPIView,), attrs)
    api_url = url(r"^api/%s" % model_name, new_api.as_view())
    urlpatterns.append(api_url)

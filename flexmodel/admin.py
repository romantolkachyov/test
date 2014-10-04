# -*- coding: utf-8 -*-
import sys
from django.contrib import admin

import models

thismodule = sys.modules[__name__]

# iterate over all created flex models and create admin class for them
for name in models.flex_model_list:
    model = getattr(models, name)
    new_admin_cls = type("%sAdmin" % name, (admin.ModelAdmin,), dict())
    admin.site.register(model, new_admin_cls)

# -*- coding: utf-8 -*-
import json
from django.shortcuts import render

from models import get_db_config


def home(request):
    db_schema = json.dumps(get_db_config())
    return render(request, "home.html", dict(db_schema=db_schema))

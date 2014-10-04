# -*- coding: utf-8 -*-
import sys
import yaml

from django.db import models

flex_model_list = []

type_field_map = {
    'char': {
        'field': models.CharField,
        'kwargs': {
            'max_length': 255,
        }
    },
    'int': {
        'field': models.IntegerField,
    },
    'date': {
        'field': models.DateTimeField,
    },
}


def get_field(type, title):
    """ Returns field ready to injection into new flex model

    NOTE: this method returns DateTimeField instead DateField for type 'date'

    :param type: (char|int|date) string
    :param title: string — the name used for user representation
    :return: models.Field
    """
    data = type_field_map[type]
    FieldClass = data['field']
    kwargs = data.get('kwargs', {})
    kwargs.update(dict(null=True))
    return FieldClass(title, **kwargs)


def make_flex_model(name, config):
    """ Make a Django model for provided config
    """
    attrs = dict(__module__='flexmodel')
    model_title = config.get('title', name)

    # Add model fields from config
    for field_def in config.get('fields', []):
        f_id = field_def['id']
        f_type = field_def['type']
        f_title = field_def['title']

        attrs[f_id] = get_field(f_type, f_title)

    model = type(name, (models.Model,), attrs)

    model._meta.verbose_name = model_title
    model._meta.verbose_name_plural = model_title

    return model


def make_all(config):
    thismodule = sys.modules[__name__]
    for model_name, model_meta in config.iteritems():
        model = make_flex_model(model_name, model_meta)
        flex_model_list.append(model_name)
        setattr(thismodule, model_name, model)


# FIXME: will loads many times
model_data = yaml.load(file('models.yaml').read())

make_all(model_data)

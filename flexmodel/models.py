# -*- coding: utf-8 -*-
import sys
import yaml

from django.conf import settings
from django.core.cache import cache
from django.apps.registry import apps

from django.db import models

# collect all created model names here
flex_model_list = []

# our type to django field map with default kwargs
# keys — our type name, value:
#  * field — django filed class
#  * kwargs — default kwargs for that field
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
        'field': models.DateField,
    },
}


def get_db_config(force=False):
    """ Load config in a cache (not so optimal)

    Use FLEXMODEL_FILE settings or 'models.yaml' by default
    """
    _config_cache = cache.get('_flex_config_cache')
    if not force and _config_cache is not None:
        return _config_cache
    filename = getattr(settings, 'FLEXMODEL_FILE', 'models.yaml')
    fp = file(filename)
    _config_cache = yaml.load(fp)
    cache.set('_flex_config_cache', _config_cache)
    return _config_cache


def get_field(config):
    """ Returns field ready to injection into new flex model
    """
    field_id = config.get('id')
    field_type = config.get('type', 'char')
    title = config.get('title', field_id)
    del config['id'], config['title'], config['type']

    data = type_field_map[field_type]
    FieldClass = data['field']
    # defaults
    kwargs = dict(null=True)
    # defaults for specified type
    kwargs.update(data.get('kwargs', {}))
    # from config
    kwargs.update(config)
    return FieldClass(title, **kwargs)


def make_flex_model(name, config):
    """ Make a Django model for provided config
    """
    attrs = dict(__module__='flexmodel')
    model_title = config.get('title', name)

    # Add model fields from config
    for field_def in config.get('fields', []):
        f_id = field_def['id']
        attrs[f_id] = get_field(field_def)

    # Create model itself
    model = type(name, (models.Model,), attrs)

    model._meta.verbose_name = model_title
    model._meta.verbose_name_plural = model_title

    return model


def make_all(config=None, force=False):
    """ Make all models from config file
    """
    if not settings.SKIP_FLEX_MODELS or force:
        flex_model_list = []
        if config is None:
            config = get_db_config(force)
        thismodule = sys.modules[__name__]

        # iterating over all defined models
        for model_name, model_meta in config.iteritems():
            model = make_flex_model(model_name, model_meta)
            flex_model_list.append(model_name)
            setattr(thismodule, model_name, model)
        apps.clear_cache()
        setattr(thismodule, 'flex_model_list', flex_model_list)


make_all()

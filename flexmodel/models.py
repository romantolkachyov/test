import sys
import yaml

from django.db import models

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
    """ Returns field ready to injection
    """
    data = type_field_map[type]
    FieldClass = data['field']
    kwargs = data.get('kwargs', {})
    kwargs.update(dict(null=True))
    return FieldClass(title, **kwargs)

# FIXME: will loads many times
model_data = yaml.load(file('models.yaml').read())

field_type_map = {
    'chart': models.CharField
}

thismodule = sys.modules[__name__]

for model_name, model_meta in model_data.iteritems():
    attrs = dict()
    model_title = model_meta['title']

    # Add model fields from config
    for field_def in model_meta.get('fields', []):
        f_id = field_def['id']
        f_type = field_def['type']
        f_title = field_def['title']

        attrs[f_id] = get_field(f_type, f_title)

    attrs['__module__'] = 'flexmodel'
    # TODO: model_title!!!

    model = type(model_name, (models.Model,), attrs)

    setattr(thismodule, model_name, model)

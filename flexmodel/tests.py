# -*- coding: utf-8 -*-
import os

from django.test.runner import DiscoverRunner
from django.test import TransactionTestCase
from django.conf import settings
from django.core.management import call_command

from flexmodel import models


class FlexTestRunner(DiscoverRunner):
    def setup_test_environment(self):
        super(FlexTestRunner, self).setup_test_environment()


class FlexModelTestCase(TransactionTestCase):
    def setUp(self):
        # Clear test migrations
        migration_dir = os.path.join(settings.BASE_DIR, 'flexmodel/test_migrations')
        try:
            for f in os.listdir(migration_dir):
                if f != '__init__.py':
                    os.unlink(os.path.join(migration_dir, f))
        except OSError:
            pass

        # Disable testing because we didn't want to skip model creation in future
        settings.SKIP_FLEX_MODELS = False

        models.make_all(force=True)

        call_command('makemigrations', 'flexmodel')
        call_command('migrate')

    def test_models(self):
        """ Проверяем наличие моделей на основе конфига
        """
        self.assertTrue(hasattr(models, 'all_field_test'))
        MyModel = models.all_field_test
        m = MyModel()
        self.assertTrue(hasattr(m, 'type_char'))
        self.assertTrue(hasattr(m, 'type_int'))
        self.assertTrue(hasattr(m, 'type_date'))
        m.save()

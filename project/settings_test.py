from settings import *

# we must skip it at startup because no migration
SKIP_FLEX_MODELS = True
MIGRATION_MODULES = {'flexmodel': 'flexmodel.test_migrations'}
FLEXMODEL_FILE = 'test_models.yaml'

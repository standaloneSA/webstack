import os
from .settings import *

DATABASES["default"]["USER"] = os.environ["MIGRATOR_DB_USER"]
DATABASES["default"]["PASSWORD"] = os.environ["MIGRATOR_DB_PASS"]

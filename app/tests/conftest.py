import os
import sys

# Ensure the app directory is importable regardless of how pytest is invoked
HERE = os.path.dirname(__file__)
APP_DIR = os.path.abspath(os.path.join(HERE, ".."))
if APP_DIR not in sys.path:
    sys.path.insert(0, APP_DIR)

import pytest  # noqa: E402


@pytest.fixture
def client():
    """Flask test client configured for the testing environment."""
    # Set env vars before importing the module so module-level reads pick them up
    os.environ.setdefault("APP_ENV", "testing")
    os.environ.setdefault("APP_VERSION", "0.0.0-test")
    os.environ.setdefault("LOG_LEVEL", "WARNING")
    os.environ.setdefault("PORT", "5000")

    from app import app

    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c

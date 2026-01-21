# Ensure repository root is on sys.path so `from app import app` works
import os
import sys

HERE = os.path.dirname(__file__)
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)

# Provide a small werkzeug shim if needed for some runner environments
try:
    import werkzeug

    if not hasattr(werkzeug, "__version__") or werkzeug.__version__ is None:
        werkzeug.__version__ = "3.1.5"
except Exception:
    # If werkzeug isn't installed in the environment, tests that require Flask
    # will fail later with a clear ImportError; ignore shim failures here.
    pass

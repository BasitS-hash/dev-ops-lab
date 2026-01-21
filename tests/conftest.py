# Test shim to ensure werkzeug exposes __version__ for Flask test utilities
import werkzeug

if not hasattr(werkzeug, "__version__") or werkzeug.__version__ is None:
    # Provide a minimal version string to satisfy Flask's version checks
    # in testing utilities (keeps this line under the configured limit)
    werkzeug.__version__ = "3.1.5"

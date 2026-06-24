"""
Root conftest.py — shared fixtures for integration-level tests.

App-unit fixtures live in app/tests/conftest.py.
Add project-wide fixtures (e.g. tmp directories, shared mocks) here.
"""
import os
import sys

# Ensure repo root is importable for all test modules
REPO_ROOT = os.path.dirname(os.path.abspath(__file__))
if REPO_ROOT not in sys.path:
    sys.path.insert(0, os.path.dirname(REPO_ROOT))

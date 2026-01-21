import pytest

from app import app


@pytest.fixture
def client():
    app.testing = True
    with app.test_client() as client:
        yield client


def test_index(client):
    r = client.get("/")
    assert r.status_code == 200
    data = r.get_json()
    assert data["message"] == "Hello from DevOps Lab"

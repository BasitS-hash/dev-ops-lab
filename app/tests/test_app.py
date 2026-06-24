"""
Comprehensive tests for the DevOps Lab Flask application.

Covers all four routes plus a 404 guard.
"""


def test_index_returns_200_and_message(client) -> None:
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["message"] == "Hello from DevOps Lab"


def test_index_returns_version_and_env(client) -> None:
    response = client.get("/")
    data = response.get_json()
    assert "version" in data
    assert "env" in data
    # Values should be non-empty strings
    assert isinstance(data["version"], str) and data["version"]
    assert isinstance(data["env"], str) and data["env"]


def test_health_returns_healthy_status(client) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
    assert "version" in data


def test_health_has_uptime_seconds(client) -> None:
    response = client.get("/health")
    data = response.get_json()
    assert "uptime_seconds" in data
    assert isinstance(data["uptime_seconds"], (int, float))
    assert data["uptime_seconds"] >= 0


def test_metrics_returns_request_count(client) -> None:
    # Make a couple of requests so the counter is definitely non-zero
    client.get("/")
    client.get("/health")
    response = client.get("/metrics")
    assert response.status_code == 200
    data = response.get_json()
    assert "requests_total" in data
    assert isinstance(data["requests_total"], int)
    assert data["requests_total"] > 0
    assert "uptime_seconds" in data
    assert "hostname" in data


def test_info_returns_app_details(client) -> None:
    response = client.get("/info")
    assert response.status_code == 200
    data = response.get_json()
    assert data["app"] == "devops-lab"
    assert "version" in data
    assert "python" in data
    assert "env" in data
    # python version should look like "3.x.y"
    assert data["python"].count(".") >= 1


def test_404_on_unknown_route(client) -> None:
    response = client.get("/does-not-exist")
    assert response.status_code == 404

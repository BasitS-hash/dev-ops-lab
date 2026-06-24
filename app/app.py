import logging
import os
import platform
import time
from typing import Any

from flask import Flask, jsonify

# ---------------------------------------------------------------------------
# Configuration — read from environment with sensible defaults
# ---------------------------------------------------------------------------
LOG_LEVEL: str = os.environ.get("LOG_LEVEL", "INFO").upper()
PORT: str = os.environ.get("PORT", "5000")
APP_ENV: str = os.environ.get("APP_ENV", "development")
APP_VERSION: str = os.environ.get("APP_VERSION", "1.0.0")

# ---------------------------------------------------------------------------
# Structured logging
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL, logging.INFO),
    format="%(asctime)s %(levelname)s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Application state
# ---------------------------------------------------------------------------
START_TIME: float = time.monotonic()
_requests_total: int = 0

# ---------------------------------------------------------------------------
# Flask app
# ---------------------------------------------------------------------------
app = Flask(__name__)


@app.before_request
def _count_request() -> None:
    """Increment the in-memory request counter before every request."""
    global _requests_total
    _requests_total += 1


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------
@app.route("/")
def index() -> Any:
    """Root endpoint — basic service identification."""
    logger.info("GET /")
    return jsonify(
        {
            "message": "Hello from DevOps Lab",
            "version": APP_VERSION,
            "env": APP_ENV,
        }
    )


@app.route("/health")
def health() -> Any:
    """Liveness/readiness probe — always returns 200 when the process is up."""
    uptime: float = round(time.monotonic() - START_TIME, 3)
    logger.info("GET /health uptime=%.3fs", uptime)
    return (
        jsonify(
            {
                "status": "healthy",
                "uptime_seconds": uptime,
                "version": APP_VERSION,
            }
        ),
        200,
    )


@app.route("/metrics")
def metrics() -> Any:
    """Lightweight in-memory metrics (no Prometheus dependency required)."""
    uptime: float = round(time.monotonic() - START_TIME, 3)
    logger.info("GET /metrics requests_total=%d", _requests_total)
    return jsonify(
        {
            "requests_total": _requests_total,
            "uptime_seconds": uptime,
            "hostname": platform.node(),
        }
    )


@app.route("/info")
def info() -> Any:
    """Static build / runtime information."""
    logger.info("GET /info")
    return jsonify(
        {
            "app": "devops-lab",
            "version": APP_VERSION,
            "python": platform.python_version(),
            "env": APP_ENV,
        }
    )


# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    logger.info("Starting DevOps Lab app on port %s (env=%s)", PORT, APP_ENV)
    app.run(host="0.0.0.0", port=int(PORT))

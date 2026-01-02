"""Health check handler."""


def get() -> tuple[str, int]:
    """Health check endpoint."""
    return "OK", 200

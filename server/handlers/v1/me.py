"""User profile handler - /v1/me"""


def get(user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get current user profile from token."""
    info = token_info or user or {}
    
    return {
        "uid": info.get("uid", ""),
        "email": info.get("email", ""),
        "displayName": info.get("name", info.get("displayName", "")),
    }, 200
